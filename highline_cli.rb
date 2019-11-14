require 'highline'

class HighlineCli
  def ask(prompt)
    cli.ask prompt do |conf|
      conf.readline = true
    end.to_s
  end

  private def cli
    @cli ||= HighLine.new
  end
end
