resource "aws_iam_role" "codepipeline" {
  name               = "${local.name_prefix}-codepipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      }
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codepipeline" {
  name   = "${local.name_prefix}-codepipeline"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRole"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        "Resource": "${aws_codecommit_repository.this.arn}"
      },
      {
          "Effect":"Allow",
          "Action": [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:PutObjectAcl",
              "s3:PutObject"
          ],
          "Resource": "${aws_s3_bucket.codepipeline_artifact.arn}/*"
      },
      {
          "Effect":"Allow",
          "Action": [
              "s3:GetBucketVersioning"
          ],
          "Resource": "${aws_s3_bucket.codepipeline_artifact.arn}"
      },
      {
        "Effect": "Allow",
        "Action": [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        "Resource": "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:project/${local.name_prefix}*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "codebuild:CreateReportGroup",
              "codebuild:CreateReport",
              "codebuild:UpdateReport",
              "codebuild:BatchPutTestCases",
              "codebuild:BatchPutCodeCoverages"
          ],
          "Resource": "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/${local.name_prefix}*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name_prefix}*",
            "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name_prefix}:*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}
