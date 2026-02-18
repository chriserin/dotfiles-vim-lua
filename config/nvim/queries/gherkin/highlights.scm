[
  (background_kw)
  (examples_kw)
  (feature_kw)
  (rule_kw)
  (scenario_kw)
  (scenario_outline_kw)
] @keyword

(given_group
  (given_step
    (given_line
      (given_kw) @keyword.given)))
(given_group
  [
    (and_step
      (and_line
        (and_kw) @keyword.given.continuation))
    (but_step
      (but_line
        (but_kw) @keyword.given.continuation))
    (asterisk_step
      (asterisk_line
        "* " @keyword.given.continuation))
  ])

(when_group
  (when_step
    (when_line
      (when_kw) @keyword.when)))
(when_group
  [
    (and_step
      (and_line
        (and_kw) @keyword.when.continuation))
    (but_step
      (but_line
        (but_kw) @keyword.when.continuation))
    (asterisk_step
      (asterisk_line
        "* " @keyword.when.continuation))
  ])

(then_group
  (then_step
    (then_line
      (then_kw) @keyword.then)))
(then_group
  [
    (and_step
      (and_line
        (and_kw) @keyword.then.continuation))
    (but_step
      (but_line
        (but_kw) @keyword.then.continuation))
    (asterisk_step
      (asterisk_line
        "* " @keyword.then.continuation))
  ])

(step_param) @variable.parameter
(quoted_string) @string

(list_item) @markup.list.gherkin

(tag) @type

(table_head_row
  (table_col
    (table_cell) @markup.heading.gherkin))

":" @punctuation.delimiter

"|" @punctuation.special

(doc_string) @string.documentation
(media_type) @type

"language" @property

(language_name) @string
(invalid_language_name) @comment.error

[
  (comment)
  (language)
] @comment
