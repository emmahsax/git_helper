# frozen_string_literal: true

module GitHelper
  class HighlineCli
    def ask(prompt)
      highline_client.ask(prompt) do |conf|
        conf.readline = true
      end.to_s
    end

    def ask_yes_no(prompt)
      answer = highline_client.ask(prompt) do |conf|
        conf.readline = true
      end.to_s

      answer.empty? ? true : !!(answer =~ /^y/i)
    end

    def ask_options(prompt, choices)
      choices_as_string_options = ''
      choices.each { |choice| choices_as_string_options << "#{choices.index(choice) + 1}. #{choice}\n" }
      compiled_prompt = "#{prompt}\n#{choices_as_string_options.strip}"

      index = highline_client.ask(compiled_prompt) do |conf|
        conf.readline = true
      end.to_i - 1

      choices[index]
    end

    private def highline_client
      @highline_client ||= HighLine.new
    end
  end
end
