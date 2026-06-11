variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website_access" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  etag         = filemd5("${path.module}/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/style.css"
  etag         = filemd5("${path.module}/style.css")
  content_type = "text/css"
}

resource "aws_s3_object" "hero_illustration" {
  bucket       = aws_s3_bucket.website.id
  key          = "assets/hero-illustration.svg"
  source       = "${path.module}/assets/hero-illustration.svg"
  etag         = filemd5("${path.module}/assets/hero-illustration.svg")
  content_type = "image/svg+xml"
}

output "bucket_name" {
  value = aws_s3_bucket.website.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.website.arn
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
