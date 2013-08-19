require_relative "./spec_helper"

describe Cocaine::Patterns do

  describe "METHOD_DEF" do

    let(:pattern) { Cocaine::Patterns::METHOD_DEF }

    let(:simple_method) { "def my_method\n" }
    let(:other_simple_method) { "def my_other_method\n" }

    it "captures the method name" do
      result_1 = simple_method.match pattern
      expect(result_1).to_not be_nil
      expect(result_1["method_name"]).to eq("my_method")

      result_2 = other_simple_method.match pattern
      expect(result_2).to_not be_nil
      expect(result_2["method_name"]).to eq("my_other_method")
    end

    it "works when a semicolon is used at the end instead of a new line" do
      method = "def method;"
      result = method.match pattern
      expect(result).to_not be_nil
    end

    it "works when there are tons of unnecessary spaces" do
      method = "    def     method  (  arg_1   ,   arg_2  =  5       , *args )  \n"
      result = method.match pattern
      expect(result).to_not be_nil
    end

    context "when the method name has a number in it" do
      it "captures the method name" do
        number_method = "def method_1\n"
        result = number_method.match pattern
        expect(result).to_not be_nil
        expect(result["method_name"]).to eq("method_1")
      end
    end

    context "when the method name has spaces in front of it" do
      it "captures the method name" do
        spaced_method = "   def method\n"
        result = spaced_method.match pattern
        expect(result).to_not be_nil
        expect(result["method_name"]).to eq("method")
      end
    end

    context "when the method name has a question mark in it" do
      let(:predicate_method) { "def my_method?\n" }

      it "captures the method name" do
        result = predicate_method.match pattern
        expect(result).to_not be_nil
        expect(result["method_name"]).to eq("my_method?")
      end
    end

    context "when the method has arguments" do
      it "captures the arguments list when there are parentheses" do
        method_with_parens = "def method(arg_1, arg_2)\n"
        result = method_with_parens.match pattern
        expect(result["args_list"]).to eq("arg_1, arg_2")
      end

      it "captures the arguments list when there are parentheses" do
        method_without_parens = "def method arg_1, arg_2\n"
        result = method_without_parens.match pattern
        expect(result["args_list"]).to eq("arg_1, arg_2")
      end

      it "captures the argument list when there's only one argument" do
        method = "def method(arg)\n"
        result = method.match pattern
        expect(result["args_list"]).to eq("arg")
      end

      it "captures the argument list when there's a splat" do
        method = "def method(*args)\n"
        result = method.match pattern
        expect(result["args_list"]).to eq("*args")
      end

      it "captures the argument list when there's a default argument" do
        method = "def method(arg = 5)\n"
        result = method.match pattern
        expect(result["args_list"]).to eq("arg = 5")
      end
    end

    context "when the method is a singleton" do
      it "captures the method name" do
        singleton = "def self.method\n"
        result = singleton.match pattern
        expect(result).to_not be_nil
        expect(result["method_name"]).to eq("method")
        expect(result["singleton"]).to eq("self.")
      end

      it "captures the argument list" do
        singleton = "def self.method arg_1\n"
        result = singleton.match pattern
        expect(result).to_not be_nil
        expect(result["args_list"]).to eq("arg_1")
        expect(result["singleton"]).to eq("self.")
      end
    end
  end

  describe "CLASS_MODULE_DEF" do

    let(:pattern) { Cocaine::Patterns::CLASS_MODULE_DEF }

    it "captures the class name" do
      class_def = "class Dog\n"
      result = class_def.match pattern
      expect(result["class_module"]).to eq("Dog")
    end

    context "when there's inheritance" do
      it "captures the class name" do
       class_def = "class Dog < Animal\n"
       result = class_def.match pattern
       expect(result["class_module"]).to eq("Dog")
      end

      it "captures the super class' name" do
        class_def = "class Dog < Animal\n"
        result = class_def.match pattern
        expect(result["super_class_name"]).to eq("Animal")
      end

      it "works when there are a ton of spaces" do
        class_def = "    class     Dog    <   Animal     \n"
        result = class_def.match pattern
        expect(result).to_not be_nil
      end

      it "works when a semicolon is used at the end instead of a new line" do
        class_def = "class Dog < Animal;"
        result = class_def.match pattern
        expect(result).to_not be_nil
      end
    end

    context "when it's a module" do
      it "captures the module name" do
        module_def = "module Walkable\n"
        result = module_def.match pattern
        expect(result).to_not be_nil
      end
    end
  end
end
