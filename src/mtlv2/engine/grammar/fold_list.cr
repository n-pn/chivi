module MtlV2::AST
  class BaseList
    def fold_inner!
      node = @head

      while node
        node.fold!(node.succ?)
        node = node.succ?
      end
    end
  end
end
