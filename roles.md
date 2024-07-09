# Rol IAM para EC2
resource "aws_iam_role" "ec2_role" {
  name = "LabRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Adjuntar Política SNS Full Access al Rol IAM
resource "aws_iam_role_policy_attachment" "sns_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Adjuntar Política Lambda Full Access al Rol IAM
resource "aws_iam_role_policy_attachment" "lambda_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Perfil de Instancia IAM para EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "LabInstanceProfile"
  role = aws_iam_role.ec2_role.name
}