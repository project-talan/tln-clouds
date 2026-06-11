#
#module "s3_processor_lambda" {
#  source  = "terraform-aws-modules/lambda/aws"
#  version = "8.8.0"
#
#  function_name = "${module.shared.k8s_name}-s3-upload-processor"
#  description   = "notification about file upload into cluster ${module.shared.k8s_name}"
#  handler       = "s3_processor.handler"
#  runtime       = "nodejs20.x"
#  source_path   = "./src/s3_processor.mjs" # шлях до коду нової лямбди
#
#  create_role = false
#  lambda_role = aws_iam_role.s3_processor_role.arn
#  # set up memory
#  memory_size = 512
#  timeout     = 10
#
#  vpc_subnet_ids         = data.aws_subnets.private.ids
#  vpc_security_group_ids = [aws_security_group.lambda_sg.id]
#
#  # Allow Terraform faster delete SG.
#  replace_security_groups_on_destroy = true
#
#  //doesnot work if create role is set to false
#  //attach_network_policy  = true
#
#  create_current_version_allowed_triggers = false
#
#  # Allow S3 call this function
#  allowed_triggers = {
#    AllowExecutionFromS3Private = {
#      principal  = "s3.amazonaws.com"
#      source_arn = module.s3_private.s3_bucket_arn
#    }
#    # second bucket
#    AllowExecutionFromS3Public = {
#      principal  = "s3.amazonaws.com"
#      source_arn = module.s3_public.s3_bucket_arn
#    }
#  }
#  //lambda could not resolbe the name with .svc.cluster.local
#  environment_variables = {
#    EKS_SERVICE_URL = "https://api.${var.env_id}.${var.domain_name}" //TODO find out the endpoint
#    SERVICE_API_KEY = "test" //TODO find out autorization
#  }
#}
#
#resource "aws_security_group" "lambda_sg" {
#  depends_on = [
#    aws_iam_role_policy_attachment.lambda_vpc_access
#  ]
#
#  name        = "${module.shared.prefix_group}-lambda-eks-client-sg"
#  description = "Allow Lambda to contact EKS services"
#  vpc_id      = data.aws_vpc.primary.id
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "lambda-to-eks-sg"
#  }
#}
#
#resource "aws_security_group_rule" "allow_lambda_to_eks" {
#  type                     = "ingress"
#  from_port                = 1
#  to_port                  = 65000
#  protocol                 = "tcp"
#  security_group_id        = data.aws_security_group.eks_cluster_sg.id # SG of your EKS
#  source_security_group_id = aws_security_group.lambda_sg.id              # SG our lambda Лямбди
#}
#
#resource "aws_security_group_rule" "allow_lambda_to_node" {
#  type                     = "ingress"
#  from_port                = 1
#  to_port                  = 65000
#  protocol                 = "tcp"
#  security_group_id        = data.aws_security_group.eks_nodes_sg.id # SG of your EKS
#  source_security_group_id = aws_security_group.lambda_sg.id              # SG our lambda Лямбди
#}
#
## 1. create role
#resource "aws_iam_role" "s3_processor_role" {
#
#  name = "${module.shared.prefix_group}-s3-processor-role"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [{
#      Action = "sts:AssumeRole"
#      Effect = "Allow"
#      Principal = {
#        Service = "lambda.amazonaws.com"
#      }
#    }]
#  })
#}
#
## 2. Plolicy
#resource "aws_iam_policy" "s3_processor_policy" {
#
#  name = "${module.shared.prefix_group}-s3-processor-policy"
#
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        # permission to read bucket
#        Action   = ["s3:GetObject", "s3:ListBucket"]
#        Effect   = "Allow"
#        Resource = [
#          module.s3_private.s3_bucket_arn,
#          module.s3_public.s3_bucket_arn
#        ]
#      },
#      {
#        # permission for cloudwatch CloudWatch
#        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
#        Effect   = "Allow"
#        Resource = "arn:aws:logs:*:*:*"
#      }
#    ]
#  })
#}
#
## 3. attach policy to role
#resource "aws_iam_role_policy_attachment" "s3_processor_attach" {
#
#  role       = aws_iam_role.s3_processor_role.name
#  policy_arn = aws_iam_policy.s3_processor_policy.arn
#}
#
##4. attache policy for network interface
#resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
#  role       = aws_iam_role.s3_processor_role.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
#}