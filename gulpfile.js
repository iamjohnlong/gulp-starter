
const gulp = require('gulp')
const browserSync = require('browser-sync').create()
const gutil = require('gulp-util')
const sourcemaps = require('gulp-sourcemaps')
const source = require('vinyl-source-stream')
const buffer = require('vinyl-buffer')
const sass = require("gulp-sass")
const rename = require('gulp-rename')

const babel = require('gulp-babel')
const rollup = require('gulp-rollup')
const npm = require('rollup-plugin-npm')
const commonjs = require('rollup-plugin-commonjs')

function compile(target, name, dest) {
  return gulp.src(target)
    .pipe(rollup({
      sourceMap: true,
      plugins: [
        npm({ jsnext: true, main: true }),
        commonjs()
      ]
    }))
    .on('error', gutil.log)
    .pipe(babel({
        presets: ['es2015']
    }))
    .on('error', gutil.log)
    .pipe(rename(name))
    .pipe(sourcemaps.write('.'))
    .pipe(gulp.dest(dest))
}

gulp.task('compileES2015', function() {
  return compile('./app/assets/index.js', 'bundle.js', './tmp/assets/js')
})

gulp.task('html', function() {
  return gulp.src('./app/index.html').pipe(gulp.dest('./tmp'))
})

gulp.task("sass", function() {
  return gulp.src('./app/assets/sass/**/*.scss').pipe(sass()).pipe(gulp.dest('./tmp/assets/css'))
})

gulp.task('watch-sass', ['sass'], browserSync.reload)
gulp.task('watch-js', ['compileES2015'], browserSync.reload)
gulp.task('watch-html', ['html'], browserSync.reload)

gulp.task('server', function() {
  browserSync.init({
    notify: false,
    server: {
      baseDir: './tmp'
    }
  })
  gulp.watch('./app/**/*.scss', ['watch-sass'])
  gulp.watch('./app/assets/**/*.js', ['watch-js'])
  gulp.watch('./app/**/*.html', ['watch-html'])
})

gulp.task('watch', function() {
  gulp.watch('app/**/*.html', ["html"])
  return gulp.watch('app/**/*.scss', ["sass"])
})

gulp.task('serve', ['server', 'html', 'sass', 'compileES2015'])

gulp.task('default', ['serve', 'server', 'watch'])
