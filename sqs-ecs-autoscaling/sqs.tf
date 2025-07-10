resource "aws_sqs_queue" "task_queue" {
  name                      = "${local.prefix}-task-queue"
  delay_seconds             = 0
  receive_wait_time_seconds = 10
  kms_master_key_id         = "alias/aws/sqs"

  tags = {
    Name = "${local.prefix}-task-queue"
  }
}

resource "aws_sqs_queue" "task_queue_dlq" {
  name              = "${local.prefix}-task-queue-dlq"
  kms_master_key_id = "alias/aws/sqs"

  tags = {
    Name = "${local.prefix}-task-queue-dlq"
  }
}

resource "aws_sqs_queue_redrive_policy" "task_queue_redrive" {
  queue_url = aws_sqs_queue.task_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.task_queue_dlq.arn
    maxReceiveCount     = 3
  })
}
