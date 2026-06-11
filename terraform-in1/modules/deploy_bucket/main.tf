resource "aws_s3_bucket" "this" {
  bucket = "in1-node-app-deploy-717221858869"
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.this.id

  key = "node-app.zip"

  source = "../node-app.zip"

  etag = filemd5("../node-app.zip")
}