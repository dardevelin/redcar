module Redcar
  class Application
    
    class CloseTreeCommand < TreeCommand
      def execute
        win = Redcar.app.focussed_window
        if win and treebook = win.treebook
          if tree = treebook.focussed_tree
            treebook.remove_tree(tree)
          end
        end
      end
    end

    class ToggleTreesCommand < TreeCommand
      def execute
        win = Redcar.app.focussed_window
        if win and treebook = win.treebook
          if win.trees_visible?
            win.set_trees_visible(false)
          else
            win.set_trees_visible(true)
          end
        end
      end
    end

    class SwitchTreeDownCommand < TreeCommand

      def execute
        win = Redcar.app.focussed_window
        win.treebook.switch_down
      end
    end

    class SwitchTreeUpCommand < TreeCommand

      def execute
        win = Redcar.app.focussed_window
        win.treebook.switch_up
      end
    end
    
    class TreebookWidthCommand < Command
      MINIMUM_TREEBOOK_WIDTH = 0
      WIDTH_INCREMENT        = 5
      sensitize :open_trees
    end
    
    class IncreaseTreebookWidthCommand < TreebookWidthCommand
      def execute
        win = Redcar.app.focussed_window
        win.treebook_width = win.treebook_width + WIDTH_INCREMENT
      end
    end
    
    class DecreaseTreebookWidthCommand < TreebookWidthCommand
      def execute
        win = Redcar.app.focussed_window
        new_width = win.treebook_width - WIDTH_INCREMENT
        unless new_width < MINIMUM_TREEBOOK_WIDTH
          win.treebook_width = new_width
        end
      end
    end

    class OpenTreeFinderCommand < TreeCommand
      def execute
        if win = Redcar.app.focussed_window
          if trees = win.treebook.trees and trees.any?
            titles = []
            trees.each {|t| titles << t.tree_mirror.title}
            dialog = TreeFuzzyFilter.new(win,titles)
            dialog.open
          end
        end
      end

      class TreeFuzzyFilter < FilterListDialog

        def initialize(win,titles)
          super()
          @win = win
          @titles = titles
        end

        def selected(text,ix)
          if tree = @win.treebook.trees.detect do |tree|
              tree.tree_mirror.title == text
            end
            if @win.treebook.focussed_tree == tree
              @win.set_trees_visible(true) if not @win.trees_visible?
            else
              @win.treebook.focus_tree(tree)
            end
            tree.focus
            close
          end
        end

        def update_list(filter)
          @titles.select do |t|
            t.downcase.include?(filter.downcase)
          end
        end
      end
    end

  end
end