require 'rubygems'

SHENRUBY_ROOT = File.expand_path(File.dirname(__FILE__))

# Import Shen Release
RELEASE_DIR = File.join(SHENRUBY_ROOT, 'shen/release')
IMPORT_DIR = File.join(SHENRUBY_ROOT, 'import')
SHEN_ZIP = File.join(IMPORT_DIR, 'Shen.zip')

namespace :shen do
  namespace :import do
    task :release => [:remove_old_release, :import_dirs, :cleanup]
    task :import_dirs => [:k_lambda, :test_programs, :benchmarks]

    task :remove_old_release do
      rm_rf IMPORT_DIR
      rm_rf RELEASE_DIR
    end

    task :cleanup do
      rm_r IMPORT_DIR
    end

    directory IMPORT_DIR
    directory RELEASE_DIR

    file SHEN_ZIP => [IMPORT_DIR] do
      sh "curl -s http://www.shenlanguage.org/Download/Shen.zip > '#{SHEN_ZIP}'"
    end

    task :unzip => SHEN_ZIP do
      sh "(cd #{IMPORT_DIR}; unzip Shen.zip)"
    end

    def dst_path(src_root, src_path, dst_root)
      path_tail = src_path[src_root.length..-1]
      File.join(dst_root, path_tail.gsub(/[\s ']/, '_'))
    end

    def import_dir(dirname)
      src_root = Dir.glob(File.join('import/Shen *', dirname)).first
      dst_root = File.join(RELEASE_DIR, dirname.downcase.gsub(/\s/, '_'))

      src_paths = Dir.glob(File.join(src_root, '**/*'))
      src_dirs, src_files = src_paths.partition { |p| File.directory?(p) }

      mkdir_p dst_root
      src_dirs.each { |dir| mkdir_p dst_path(src_root, dir, dst_root) }
      src_files.each { |file| cp file, dst_path(src_root, file, dst_root) }
    end

    def fix_load_paths(path)
      lines = File.readlines(path)
      File.open(path, 'w') do |f|
        lines.each do |l|
          if l =~ /\(load\s+"([^"]+)"\)/
            path = $1
            new_path = path.gsub(/[\s']/, '_')
            l.sub!(path, new_path)
          end
          f.puts l
        end
      end
    end

    task :k_lambda => [:unzip, RELEASE_DIR] do
      import_dir('K Lambda')
    end

    task :test_programs => [:unzip, RELEASE_DIR] do
      import_dir('Test Programs')
      fix_load_paths(File.join(RELEASE_DIR, 'test_programs/tests.shen'))
    end

    task :benchmarks => [:unzip, RELEASE_DIR] do
      import_dir('Benchmarks')
      fix_load_paths(File.join(RELEASE_DIR, 'benchmarks/benchmarks.shen'))
    end
  end
end

task :default => [:spec, :k_lambda_spec]
