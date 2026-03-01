# frozen_string_literal: true

module MARS
  module Hooks
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def before_run(&block)
        before_run_hooks << block
      end

      def after_run(&block)
        after_run_hooks << block
      end

      def before_run_hooks
        @before_run_hooks ||= []
      end

      def after_run_hooks
        @after_run_hooks ||= []
      end
    end

    def run_before_hooks(context)
      self.class.before_run_hooks.each { |hook| hook.call(context, self) }
    end

    def run_after_hooks(context, result)
      self.class.after_run_hooks.each { |hook| hook.call(context, result, self) }
    end
  end
end
