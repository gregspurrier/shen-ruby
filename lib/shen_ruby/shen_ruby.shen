(package shen-ruby [rb-to-l rb-to-v]

\\ Convert a Ruby Enumerable to a Shen vector
(define rb-to-l
  Enum -> (reverse (rb.reduce Enum [] & (/. L X (cons X L))))
          where (rb.kind_of? Enum rb.#Enumerable)
  X -> (error (make-string "'~A' is not a Ruby Enumerable" X)))

(systemf rb-to-l)

\\ Convert a Ruby Enumerable to a Shen vector
(define rb-to-v
  Enum -> (let Array (rb.to_a Enum)
               Size (rb.size Array)
               Vector (vector Size)
               (rb-to-v-helper Array Vector Size))
  X -> (error (make-string "'~A' is not a Ruby Enumerable" X)))

(systemf rb-to-v)

(define rb-to-v-helper
  A V 0 -> V
  A V Index -> (do (vector-> V Index (rb.<- A (- Index 1)))
                   (rb-to-v-helper A V (- Index 1))))

)
