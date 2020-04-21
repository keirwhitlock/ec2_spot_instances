resource "aws_iam_role" "web_app_role" {
  name = "web_app_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "web_app_role"
  }
}

resource "aws_iam_instance_profile" "web_app_profile" {
  name = "web_app_profile"
  role = "${aws_iam_role.web_app_role.name}"
}