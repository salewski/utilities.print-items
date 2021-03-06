;;;; util.lisp --- Utilities used by the utilities.print-items system.
;;;;
;;;; Copyright (C) 2013 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:print-items)

(defun+ item-< ((key-left  &ign &optional &ign constraints-left)
                (key-right &ign &optional &ign constraints-right))
  "Return non-nil if the left item should be placed before the right."
  (let+ (((&flet+ satisfied? ((kind arg) other transpose?)
            (ecase kind
              (:after  (and transpose? (eql other arg)))
              (:before (and (not transpose?) (eql other arg)))))))
    (or (some (rcurry #'satisfied? key-right nil) constraints-left)
        (some (rcurry #'satisfied? key-left t)    constraints-right))))

(defun sort-with-partial-order (list predicate)
  (dotimes (i (factorial (length list)))
    (unless
        (iter outer
              (for i :below (length list))
              (iter (for j :from (1+ i) :below (length list))
                    (when (funcall predicate (nth j list) (nth i list))
                      (rotatef (nth i list) (nth j list))
                      (return-from outer t))))
      (return-from sort-with-partial-order list)))
  (error "~<~S does not define a partial order on ~
          ~S.~@:>~%Problems:~%~{* ~{~A - ~A~}~^~%~}"
         (list predicate list)
         (iter outer
               (for i :below (length list))
               (iter (for j :from (1+ i) :below (length list))
                     (when (funcall predicate (nth j list) (nth i list))
                       (in outer (collect (list (nth i list) (nth j list)))))))))
