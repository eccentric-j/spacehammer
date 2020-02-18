(local fu hs.fnutils)

"
Functional Programming Utilities
While Hammerspoon does provide a functional utils lib, the args are in an order
that does not play nicely with composition.

For instance hs.fnutils.map has a signature of [ table ] -> f -> [ table ]
These utils consistently reverse the order so that data is always last making it
easier to partially apply, or in the future, curry, these functions.
"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Utils
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn call-when
  [f]
  "
  Takes a value (f) that could be a function
  If f is a callable function, returns the result of the function
  Otherwise returns nil
  Useful for calling an optional callback

  Example:
  (global close-modal (fn []
                       (print \"Close!\")
                       (global close-modal nil)))
  (call-when close-modal)
  ;; => \"Close!\"
  (call-when close-modal)
  ;; No message printed but no error
  "
  (when (and f (= (type f) :function))
    (f)))

(fn contains?
  [x xs]
  "
  Takes a value and a table list
  Returns true if table list contains the value x.

  Example:
  (contains? 1 [1 2 3]) ;; => true
  "
  (and xs (fu.contains xs x)))

(fn find
  [f tbl]
  "
  Takes a predicate function and a table list of values.
  Predicate function will receive every value in list
  and should return either true or false.
  Returns the first value that matches the predicate or nil
  if no value could be found.

  Example:
  (find #(< 2 $1) [1 2 3]) ;; => 3
  "
  (fu.find tbl f))

(fn get
  [prop-name tbl]
  (if tbl
      (. prop-name tbl)
      (fn [tbl]
        (. tbl prop-name))))

(fn has-some?
  [list]
  (and list (< 0 (length list))))

(fn identity
  [x] x)

(fn join
  [sep list]
  (table.concat list sep))

(fn last
  [list]
  (. list (length list)))

(fn logf
  [...]
  (let [prefixes [...]]
    (fn [x]
      (print (table.unpack prefixes) (hs.inspect x)))))

(fn noop
  []
  nil)

(fn slice-end-idx
  [end-pos list]
  (if (< end-pos 0)
    (+ (length list) end-pos)
    end-pos))

(fn slice-start-end
  [start end list]
  (let [end+ (if (< end 0)
              (+ (length list) end)
              end)]
    (var sliced [])
    (for [i start end+]
      (table.insert sliced (. list i)))
    sliced))

(fn slice-start
  [start list]
  (slice-start-end start (length list) list))

(fn slice
  [start end list]
  (if (and (= (type end) :table)
           (not list))
      (slice-start start end)
      (slice-start-end start end list)))

(fn split
  [separator str]
  "Using specified separator, convert string to an array of strings."
  (fu.split str separator))

(fn tap
  [f x ...]
  (f x (table.unpack [...]))
  x)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce Primitives
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn seq?
  [tbl]
  (~= (. tbl 1) nil))

(fn seq
  [tbl]
  (if (seq? tbl)
    (ipairs tbl)
    (pairs tbl)))

(fn reduce
  [f acc tbl]
  (var result acc)
  (each [k v (seq tbl)]
    (set result (f result v k)))
  result)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reducers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn for-each
  [f tbl]
  (fu.each tbl f))

(fn get-in
  [paths tbl]
  (reduce
   (fn [tbl path]
     (-?> tbl (. path)))
   tbl
   paths))

(fn map
  [f tbl]
  (reduce
    (fn [new-tbl v k]
      (table.insert new-tbl (f v k))
      new-tbl)
    []
    tbl))

(fn merge
  [...]
  (let [tbls [...]]
    (reduce
     (fn merger [merged tbl]
       (each [k v (pairs tbl)]
         (tset merged k v))
       merged)
     {}
     tbls)))

(fn filter
 [f tbl]
 (reduce
  (fn [xs v k]
   (when (f v k)
    (table.insert xs v))
   xs)
  []
  tbl))

(fn concat
 [...]
 (reduce
  (fn [cat tbl]
    (each [_ v (ipairs tbl)]
      (table.insert cat v))
    cat)
  []
  [...]))

(fn some
  [f tbl]
  (let [filtered (filter f tbl)]
    (<= 1 (length filtered))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Others
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn eq?
  [l1 l2]
  (if (and (= (type l1) (type l2) "table")
           (= (length l1) (length l2)))
      (fu.every l1
                (fn [v] (contains? v l2)))
      (= (type l1) (type l2))
      (= l1 l2)
      false))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exports
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

{:call-when call-when
 :concat    concat
 :contains? contains?
 :eq?       eq?
 :filter    filter
 :find      find
 :for-each  for-each
 :get       get
 :get-in    get-in
 :has-some? has-some?
 :identity  identity
 :join      join
 :last      last
 :logf      logf
 :map       map
 :merge     merge
 :noop      noop
 :reduce    reduce
 :seq       seq
 :seq?      seq?
 :some      some
 :slice     slice
 :split     split
 :tap       tap}
