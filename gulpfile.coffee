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

bundler           = watchify(browserify('./app/assets/index.js', watchify.args))


bundle = ->
  bundler.bundle()
    .on('error', gutil.log.bind(gutil, 'Browserify Error'))
    .pipe(source('bundle.js'))
    # .pipe(buffer())
    # .pipe(sourcemaps.init(loadMaps: true))
    # .pipe(sourcemaps.write('./'))
    .pipe gulp.dest('./tmp/assets/js')
    .pipe reload
      stream: true

# so you can run `gulp js` to build the file
bundler.on 'update', bundle
# on any dep update, runs the bundler
bundler.on 'log', gutil.log

gulp.task 'js', bundle

gulp.task 'components', ['server'], ->
  gulp.src './app/assets/components/**/*'
    .pipe gulp.dest './tmp/assets/components'

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

gulp.task 'serve', ['server', 'html', 'sass', 'js', 'components']

gulp.task 'default', ['serve', 'server', 'watch']
