require "set"

module Sg
  module SemigroupHelper
    def error(msg,type=ArgumentError)
      raise ArgumentError, "Sg error: " + msg
    end

    def validate
      error "Wrong number of given elements." if @order**2 != @table.size
      error "Table contains unknown elements." if @table.any? { |x| x.nil? }

      non_associative = @elements.product(@elements, @elements).find do |x,y,z|
        self[self[x,y],z] != self[x,self[y,z]]
      end
      
      error "Given table is not associative." if !!non_associative
    end
  end
  
  class Semigroup
    include SemigroupHelper
    
    def initialize(table, elements)
      @elements = elements
      
      @internal = {}
      @elements.each_with_index { |x,i| @internal[x] = i }
      
      @table = table.map { |x| @internal[x] }
      @order = @elements.size

      validate            
    end

    attr_reader :elements, :order, :internal, :table
    
    def [](*args)
      int_args = args.map { |x| @internal[x] }

      error "Arglist contains unknown elements." if int_args.any? { |x| x.nil? }
      
      while int_args.size > 1
        x,y = int_args[0,2]
        result = @table[@order*x +y]
        int_args[0,2] = result
      end

      @elements[int_args[0]]
    end

    def identity
      @elements.find {|e| @elements.all? {|x| [self[e,x], self[x,e]] == [x,x] }}
    end

    def zero
      @elements.find {|n| @elements.all? {|x| [self[n,x],self[x,n]] == [n,n] }}
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
   
    def equivalence(*args)
      result = args | args.map { |x,y| [y,x] } | @elements.map { |x| [x,x] }

      finished = false

      until finished
        finished = true

        new_tuples = []
        result.each do |a,b|
          new_tuples |= result.find_all { |x,y| x == b && !result.include?([a,y]) }.
            map { |x,y| [a,y] }
        end
        
        unless new_tuples.empty?
          result |= new_tuples
          finished = false
        end
      end

      result.to_set
    end

    def congruence(*args)
      result = []
      args.each do |x,y|
        result |= ideal(x).to_a.product ideal(y).to_a
      end
        
      equivalence(*result)
    end
  end
end
