(defface section-title
  '((t :weight bold :inherit font-lock-keyword-face))
  "Face for highlighting the current section's title."
  :group 'section-faces)


(defface section-highlight
  '((t :inherit highlight))
  "Face for highlighting the current section at point"
  :group 'section-faces)


(defun section-insert-header (title)
  (insert (propertize title 'section-header t 'face 'section-title) "\n"))


(defun section-insert-body (body)
  (insert (propertize body 'section-body t)
          "\n"
          (propertize "\n" 'section-end t)))


(defun section-insert (title body)
  (section-insert-header title)
  (section-insert-body body))


(defun section-first ()
  ;; TODO check if this buffer contains any of the correct sections?
  (interactive)
  (goto-char (text-property-any (point-min) (point-max) 'section-header t)))


(defun section-next ()
  (interactive)
  (let ((current-section-end (next-single-property-change (point) 'section-end)))
    (when current-section-end
        (goto-char (+ 1 current-section-end)))))


(defun section-prev ()
  (interactive)
  (let* ((search-pos (max (- (point) 1) (point-min)))
         (previous-section-end (previous-single-property-change search-pos 'section-end)))
    (if previous-section-end
        (goto-char previous-section-end)
      (section-first))))


(defun section-highlight-current ()
  (when (equal major-mode 'section-mode)
    (save-excursion
      (let ((section-end (progn (section-next) (point)))
            (section-start (progn (section-prev) (point))))
        (move-overlay section-mode-highlight-overlay section-start section-end)
        (overlay-put section-mode-highlight-overlay 'face 'section-highlight)))))


(setq section-mode-keymap (make-sparse-keymap))
(define-key section-mode-keymap (kbd "n") 'section-next)
(define-key section-mode-keymap (kbd "p") 'section-prev)


(define-derived-mode section-mode fundamental-mode "section-mode"
  (turn-on-auto-fill)
  (setq-local section-mode-highlight-overlay (make-overlay (point-min) (point-max)))
  (use-local-map section-mode-keymap))


(add-hook 'post-command-hook 'section-highlight-current)


