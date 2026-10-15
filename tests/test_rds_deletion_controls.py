"""Test real Terraform input/default/forwarding expressions without cloud providers.

The fixture copies the PostgreSQL variable and locals from app, the relevant module
arguments, and the shared RDS variable/forwarding expressions. It replaces unrelated
infrastructure with a local module exposing the values sent to the pinned RDS module.
This checks configuration wiring, not AWS deletion or snapshot execution.
"""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


def block(text, declaration):
    """Extract an HCL block, respecting strings and comments while balancing braces."""
    start = text.index(declaration)
    opening = text.index('{', start + len(declaration))
    depth, quoted, escaped, comment = 0, False, False, None
    i = opening
    while i < len(text):
        c, pair = text[i], text[i:i + 2]
        if comment == 'line':
            if c == '\n':
                comment = None
        elif comment == 'block':
            if pair == '*/':
                comment = None
                i += 1
        elif quoted:
            if escaped:
                escaped = False
            elif c == '\\':
                escaped = True
            elif c == '"':
                quoted = False
        elif pair == '/*':
            comment = 'block'
            i += 1
        elif c == '#' or pair == '//':
            comment = 'line'
        elif c == '"':
            quoted = True
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return text[start:i + 1]
        i += 1
    raise ValueError('Unterminated HCL block: ' + declaration)


def expression(text, name):
    match = re.search(r'^\s*' + re.escape(name) + r'\s*=\s*(.+)$', text, flags=re.M)
    return match[1].split('#')[0].strip() if match else None


def prepare_fixture(source, directory):
    app = source / 'aws/app'
    shared = source / 'aws/shared/rds'
    variable = block((app / 'variables.tf').read_text(), 'variable "postgresql"')
    postgres = (app / 'postgres.tf').read_text()
    local = block(postgres, 'locals')
    parent = block(postgres, 'module "rds"')
    child = block((shared / 'main.tf').read_text(), 'module "rds_pg"')
    required = re.search(r'required_version\s*=\s*"([^"]+)"', (app / 'versions.tf').read_text())[1]
    arguments = []
    for key in ('rds_deletion_protection', 'rds_skip_final_snapshot'):
        value = expression(parent, key)
        if value is not None:
            arguments.append(f'  {key} = {value}')
    (directory / 'main.tf').write_text(
        'terraform {\n  required_version = ' + json.dumps(required) + '\n}\n'
        + variable + '\n' + local + '\nmodule "rds" {\n  source = "./rds"\n'
        + '\n'.join(arguments) + '\n}\n'
        + 'output "controls" {\n  value = module.rds.controls\n}\n'
        + 'output "settings" {\n  value = var.postgresql\n}\n')
    (directory / 'rds').mkdir()
    child_variables = (shared / 'variables.tf').read_text()
    (directory / 'rds/main.tf').write_text(
        block(child_variables, 'variable "rds_deletion_protection"') + '\n'
        + block(child_variables, 'variable "rds_skip_final_snapshot"') + '\n'
        + 'output "controls" {\n  value = {\n'
        + '    deletion_protection = ' + expression(child, 'deletion_protection') + '\n'
        + '    skip_final_snapshot = ' + expression(child, 'skip_final_snapshot') + '\n'
        + '  }\n}\n')


UNSET = object()


class RDSDeletionControlsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        temporary = tempfile.TemporaryDirectory(prefix='rds-controls-')
        cls.addClassCleanup(temporary.cleanup)
        cls.directory = Path(temporary.name)
        prepare_fixture(OPTIONS.source_tree, cls.directory)
        cls.environment = {k: os.environ[k] for k in ('PATH', 'HOME') if k in os.environ}
        cls.environment.update(CHECKPOINT_DISABLE='1', TF_IN_AUTOMATION='1')
        cls.run_terraform('init', '-backend=false', '-input=false', '-no-color')
        cls.run_terraform('validate', '-no-color')
        cls.defaults = cls.render()
        cls.legacy = {k: v for k, v in cls.defaults['settings'].items()
                      if k not in ('deletion_protection', 'skip_final_snapshot')}

    @classmethod
    def run_terraform(cls, *args, success=True):
        result = subprocess.run(['terraform', f'-chdir={cls.directory}', *args],
            env=cls.environment, text=True, capture_output=True)
        if success and result.returncode:
            raise AssertionError(result.stdout + result.stderr)
        return result

    @classmethod
    def render(cls, settings=UNSET, success=True):
        args = ['plan', '-input=false', '-no-color', '-out=controls.tfplan']
        if settings is not UNSET:
            inputs = cls.directory / 'case.tfvars.json'
            inputs.write_text(json.dumps({'postgresql': settings}))
            args.append('-var-file=' + str(inputs))
        result = cls.run_terraform(*args, success=success)
        if not success:
            return result
        plan = json.loads(cls.run_terraform('show', '-json', 'controls.tfplan').stdout)
        if any(c.get('mode') == 'managed' for c in plan.get('resource_changes', [])):
            raise AssertionError('The fixture must not create infrastructure')
        return {name: value['value'] for name, value in plan['planned_values']['outputs'].items()}

    def test_default_configuration_protects_data(self):
        self.assertEqual(self.defaults['controls'],
                         {'deletion_protection': True, 'skip_final_snapshot': False})

    def test_existing_configuration_gets_safe_optional_defaults(self):
        self.assertEqual(self.render(self.legacy)['controls'],
                         {'deletion_protection': True, 'skip_final_snapshot': False})

    def test_null_fields_use_safe_optional_defaults(self):
        settings = dict(self.legacy, deletion_protection=None, skip_final_snapshot=None)
        self.assertEqual(self.render(settings)['controls'],
                         {'deletion_protection': True, 'skip_final_snapshot': False})

    def test_disposable_environment_can_explicitly_opt_out(self):
        settings = dict(self.legacy, deletion_protection=False, skip_final_snapshot=True)
        self.assertEqual(self.render(settings)['controls'],
                         {'deletion_protection': False, 'skip_final_snapshot': True})

    def test_controlled_deletion_can_keep_final_snapshot(self):
        settings = dict(self.legacy, deletion_protection=False, skip_final_snapshot=False)
        self.assertEqual(self.render(settings)['controls'],
                         {'deletion_protection': False, 'skip_final_snapshot': False})

    def test_controls_remain_independent(self):
        for protection in (True, False):
            for skip in (True, False):
                with self.subTest(protection=protection, skip=skip):
                    expected = {'deletion_protection': protection, 'skip_final_snapshot': skip}
                    self.assertEqual(self.render(dict(self.legacy, **expected))['controls'], expected)

    def test_invalid_boolean_values_are_rejected(self):
        for field in ('deletion_protection', 'skip_final_snapshot'):
            with self.subTest(field=field):
                result = self.render(dict(self.legacy, **{field: 'invalid'}), success=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('bool', result.stderr)

    def test_unrelated_postgresql_settings_are_preserved(self):
        settings = dict(self.legacy, deletion_protection=True, skip_final_snapshot=False)
        actual = self.render(settings)['settings']
        self.assertEqual({k: actual[k] for k in self.legacy}, self.legacy)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-tree', type=Path, default=Path(__file__).resolve().parents[1])
    OPTIONS, unittest_args = parser.parse_known_args()
    unittest.main(argv=[__file__, *unittest_args])
