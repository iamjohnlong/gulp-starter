gulp              = require('gulp')
browserSync       = require('browser-sync')
reload            = require('browser-sync').reload
gutil             = require('gulp-util')
sourcemaps        = require('gulp-sourcemaps')
source            = require('vinyl-source-stream')
buffer            = require('vinyl-buffer')
watchify          = require('watchify')
browserify        = require('browserify')
sass              = require("gulp-sass")
babelify          = require("babelify")
bundler           = watchify(browserify('./app/assets/index.js', watchify.args))

bundler = browserify({
  debug: true,
  entries: ['./app/assets/index.js'],
  cache: {},
  packageCache: {},
  plugin: [watchify],
  transform: [
    babelify.configure({
      presets: ['es2015'],
    })
  ]
})

bundle = ->
  bundler.bundle()
    .on('error', gutil.log.bind(gutil, 'Browserify Error'))
    .pipe(source('bundle.js'))
    .pipe(gulp.dest("./tmp/assets/js"))
    .pipe(reload({
      stream: true
    }))
# so you can run `gulp js` to build the file
bundler.on 'update', bundle
# on any dep update, runs the bundler
bundler.on 'log', gutil.log

gulp.task 'js', bundle

gulp.task 'html', ->
  gulp.src './app/index.html'
    .pipe gulp.dest './tmp'

gulp.task "sass", ->
  gulp.src './app/assets/sass/**/*.scss'
    .pipe sass()
    .pipe gulp.dest './tmp/assets/css'
    .pipe reload
      stream: true

gulp.task 'server', ()->
  browserSync({
    notify: false,
    server: {
      baseDir: './tmp'
    }
  })

gulp.task 'watch', ->
  gulp.watch 'app/**/*.html', ["html"]
  gulp.watch 'app/**/*.scss', ["sass"]

gulp.task 'serve', ['server', 'html', 'sass', 'js']

gulp.task 'default', ['serve', 'server', 'watch']
