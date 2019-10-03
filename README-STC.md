# VOD STC

## REQUIREMENTS

* docker >= 19.03.2
* docker-compose >= 1.23.1

## DOCKER BUILD

```
docker build -t nginx-vod:1.0.0 . 
```

## PREPARE & LAUNCH

At first you need to create folder `mnt-data` in the respository root.

In this folder you can create any folder you want to store your mp4 videos.

And now, you can start the server:

```
docker-compose up
```

## BASIC USAGE

For example, you've created a folder named `my-first-video` in `mnt-data`. In this folder you've put the video `video.mp4`.

<!-- language: lang-none -->
```
- project home -
  |_ README.md
  |_ Dockerfile
  |_ ...
  |_ mnt-data/
     |_ my-first-video/
        |_ video.mp4
```
<!-- language: markdown -->

Now, you can get the MPD manifest with the following URL: `http://localhost:8080/dash/my-first-video/video.mp4/manifest.mpd`

## EXTENDED USAGE

For example, you've created a folder named `my-first-video` in `mnt-data`. In this folder you have the following files.

<!-- language: lang-none -->
```
- project home -
  |_ README.md
  |_ Dockerfile
  |_ ...
  |_ mnt-data/
     |_ my-first-video/
        |_ 210221431-5d4b1a5d3a155-1565203264.ttml
        |_ 210221431-5d4b1a5d3a155-0987654321.ttml
        |_ 210221431-5d4b1a5d3a155-standard5.mp4
```
<!-- language: markdown -->

You want to generate a manifest describing the video and list selected subtitles files (only TTML), you could do this using the following URL: http://nginx.mca.integ.ftven.net/dash/medias/210221431-5d4b1a5d3a155-,standard5.mp4,1565203264.ttml,0987654321.ttml,.urlset/manifest.mpd