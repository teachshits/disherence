module MiniMagick
  class CommandBuilder
    def command
      args = @args.dup
      args.delete('-quiet') if MiniMagick.processor == :gm
      "#{MiniMagick.processor} #{@command} #{args.join(' ')}".strip
    end
  end
end