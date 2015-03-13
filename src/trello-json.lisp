(in-package :cl-user)
(defpackage trello-json
  (:use :cl)
  (:export :simplify))
(in-package :trello-json)

(defun simplify (pathname &optional (stream *standard-output*))
  (let* ((board (yason:parse pathname))
         (board-name (gethash "name" board))
         (labels (gethash "labelNames" board))
         (lists-name (make-hash-table :test #'equal))
         (lists-cards (make-hash-table :test #'equal))
         (cards (gethash "cards" board))
         (checklists (make-hash-table :test #'equal)))
    ;; Extract list IDs
    (loop for list in (gethash "lists" board) do
      (let ((list-name (gethash "name" list))
            (list-id (gethash "id" list)))
        (setf (gethash list-id lists-name) list-name)))
    ;; Extract all checklists and their items
    (loop for checklist in (gethash "checklists" board) do
      (setf (gethash (gethash "id" checklist) checklists)
            (list :name (gethash "name" checklist)
                  :items (loop for item in (gethash "checkItems" checklist)
                               collecting
                           (list :name (gethash "name" item)
                                 :state (let ((state (gethash "state" item)))
                                          (if (equal state "complete")
                                              t)))))))
    ;; Extract cards
    (loop for card in cards do
      (let ((list-id (gethash "idList" card))
            (card-labels (gethash "labels" card)))
        (push (list :title (gethash "name" card)
                    :desc (gethash "desc" card)
                    :labels (loop for label in card-labels collecting
                                                           (gethash "name" label))
                    :checklists (loop for id in (gethash "idChecklists" card)
                                      collecting
                                      (gethash id checklists)))
              (gethash list-id lists-cards))))
    ;; Assemble all the data we have extracted
    (yason:with-output (stream :indent t)
      (yason:with-object ()
        (yason:encode-object-elements
         "type" "board"
         "name" board-name)
        (yason:with-object-element ("labels")
          (yason:with-object ()
            (loop for color being the hash-keys of labels
                  for name being the hash-values of labels
                  do
              (yason:encode-object-element color name))))
        (yason:with-object-element ("lists")
          (yason:with-array ()
            (loop for list-id being the hash-keys of lists-name do
              (let ((list-name (gethash list-id lists-name)))
                (yason:with-object ()
                  (yason:encode-object-elements
                   "type" "list"
                   "name" list-name)
                  (yason:with-object-element ("cards")
                    (yason:with-array ()
                      (loop for card in (reverse (gethash list-id lists-cards)) do
                        (yason:with-object ()
                          (yason:encode-object-elements
                           "type" "card"
                           "title" (getf card :title)
                           "desc" (getf card :desc)
                           "labels" (getf card :labels))
                          (yason:with-object-element ("checklists")
                            (yason:with-array ()
                              (loop for checklist in (getf card :checklists) do
                                (yason:with-object ()
                                  (yason:encode-object-element
                                   "name" (getf checklist :name))
                                  (yason:with-object-element ("items")
                                    (yason:with-array ()
                                      (loop for item in (getf checklist :items) do
                                        (yason:with-object ()
                                          (yason:encode-object-elements
                                           "name" (getf item :name)
                                           "state" (getf item :state)))))))))))))))))))))
    t))
