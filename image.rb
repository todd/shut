require 'rmagick'
require 'aws/s3'

class Image < Struct.new(:handle)
  BASE_IMAGE_PATH = ENV['BASE_IMAGE_PATH']
  S3_PATH_PREFIX  = "shut_images"

  def to_blob
    image = Magick::Image.read(BASE_IMAGE_PATH).first
    text  = Magick::Draw.new

    text.pointsize = 25
    text.gravity   = Magick::NorthGravity

    text.annotate(image, 0,0,0,15, 'SHUT THE FUCK UP')
    text.annotate(image, 0,0,0,50, handle.upcase)

    image.to_blob
  end

  def create_and_upload
    blob = to_blob
    bucket.objects.create(key, blob)
  end

  def key
    File.join(S3_PATH_PREFIX, "#{handle}.png")
  end

  def exists?
    s3_object.exists?
  end

  def url
    s3_object.public_url.to_s
  end

  private

  def s3_client
    @s3 ||= AWS::S3.new(
      access_key_id:     ENV['S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
    )
  end

  def bucket
    @bucket ||= s3_client.buckets[ENV['S3_BUCKET']]
  end

  def s3_object
    @object ||= bucket.objects[key]
  end
end
