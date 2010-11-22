require "set"

module Sg
  class Semigroup
    def initialize(table, elements)
      @elements = elements
      
      @internal = {}
      @elements.each_with_index { |x,i| @internal[x] = i }
      
      @table = table.map { |x| @internal[x] }
      @order = @elements.size

      #Validation
      if @order**2 != @table.size
        raise ArgumentError, "Sg error: wrong number of given elements."
      end

      if @table.any? { |x| x.nil? }
        raise ArgumentError, "Sg error: Table contains unknown elements."
      end

      @elements.product(@elements, @elements).each do |x,y,z|
        if self[self[x,y],z] != self[x,self[y,z]]
          raise ArgumentError, "Sg error: Given table is not associative '(#{x}#{y})#{z} != #{x}(#{y}#{z})'."
        end
      end
    end

    attr_reader :elements, :order, :internal, :table
    
    def [](*args)
      internal_args = args.map { |x| @internal[x] }

      if internal_args.any? { |x| x.nil? }
        raise ArgumentError, "Sg error: Arglist contains unknown elements."
      end
      
      while internal_args.size > 1
        x,y = internal_args[0,2]
        result = @table[@order*x +y]
        internal_args[0,2] = result
      end

      @elements[internal_args[0]]
    end

    def identity
      @elements.find { |e| @elements.all? {|x| self[e,x] == x && self[x,e] == x } }
    end

    def zero
      @elements.find { |n| @elements.all? {|x| self[n,x] == n && self[x,n] == n } }
    end

    def adjoin!(type, name = nil, force = false)
      if force || !self.send(type)
        name ||= type.to_s
        @elements << name
        @internal[name] = @order
        @order += 1

        (@order - 1).times do |i|
          index = @order*(i+1) - 1
          element = ( type == :zero ? @order - 1 : i )
          @table.insert index, element
        end

        last_row = ( type == :zero ? [@order -1]*@order : (0...@order).to_a )
        @table += last_row
      end
    end

    def left_ideal(*args)
      result = args.inject([]) { |idl,x| idl | @elements.map { |y| self[y,x] } }

      (result | args).to_set
    end

    def right_ideal(*args)
      result = args.inject([]) { |idl,x| idl | @elements.map { |y| self[x,y] } }

      (result | args).to_set
    end

    def ideal(*args)
      left_ideal(*args) | right_ideal(*args) | left_ideal(*right_ideal(*args))
    end
  end
end
