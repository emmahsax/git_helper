require 'highline'

module GitHelper
  class HighlineCli
    def ask(prompt)
      cli.ask(prompt) do |conf|
        conf.readline = true
      end.to_s
    end

    def ask_options(prompt, choices)
      choices_as_string_options = ''
      choices.each { |choice| choices_as_string_options << "#{choices.index(choice) + 1}. #{choice}\n" }
      compiled_prompt = "#{prompt}\n#{choices_as_string_options.strip}"

      cli.ask(compiled_prompt) do |conf|
        conf.readline = true
      end.to_i - 1
    end

    private def cli
      @cli ||= HighLine.new
    end
  end
end
