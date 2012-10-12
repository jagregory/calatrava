module Calatrava

  class Manifest
    def initialize(path, app_dir, kernel, shell)
      @path, @kernel, @shell = path, kernel, shell
      @feature_list = YAML.load(IO.read("#{@path}/#{app_dir}/manifest.yml"))
    end

    def features
      @feature_list
    end

    def load_file(target_dir, js_load_path, options)
      File.open("#{target_dir}/load_file.#{options[:type]}", "w+") do |f|
        @feature_list.each do |feature|
          coffee_files(feature, :include_pages => options[:include_pages]).each do |coffee_file|
            js_src = File.join(js_load_path, File.basename(coffee_file, '.coffee') + ".js")
            f.puts self.send(options[:type], js_src)
          end
        end
      end
    end

    def coffee_files
      [@shell, @kernel].collect do |src|
        src.coffee_files + feature_files(src, :coffee)
      end.flatten
    end

    def haml_files
      @shell.haml_files + feature_files(@shell, :haml)
    end
    
    def css_files
      @shell.css_files
    end

    def feature_files(source, type)
      source.features.select { |f| @feature_list.include?(f[:name]) }.collect { |f| f[type] }.flatten
    end

    def haml(js_src)
      %{%script(type="text/javascript" src="#{js_src}")}
    end

    def text(js_src)
      js_src
    end
  end

end
