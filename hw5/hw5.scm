#lang racket

;;(define (null-ld? obj) 
(define null-ld?
	(lambda (obj)
			(if (not(pair? obj)) #f  ;; if it is even not a pair, return false
				(eq? (car obj) (cdr obj))))) ;; check if it satisfied the requirement


;;(listdiff? obj) 
(define listdiff?
	(lambda (obj)
		(cond 
			[(not (pair? obj)) #f] ;; if it is not pair
			[(null-ld? obj) #t] ;; if the listdiff is empty 
			[(or (null? obj) (null? (car obj))) #f]  ;; if the object is null or the car is null
			[(not (pair? (car obj))) #f]  
			[else (listdiff? (cons (cdr (car obj)) (cdr obj)))] 
			)))


;;(cons-ld obj listdiff)
(define cons-ld 
	(lambda (obj listdiff) 
		(if (listdiff? listdiff) (cons (cons obj (car listdiff)) (cdr listdiff)) 
			"error")))


;;(car-ld listdiff)
(define car-ld
	(lambda (listdiff)
		(if (or (not (listdiff? listdiff)) (null-ld? listdiff)) ;; not listdiff or listdiff is empty 
			"error" 
			(car (car listdiff)))))


;;(cdr-ld listdff)
(define cdr-ld
	(lambda (listdiff)
		(if (and (listdiff? listdiff) (not (eq? (car listdiff) (cdr listdiff))))
			(cons (cdr (car listdiff)) (cdr listdiff))
			"error"))) 

;; (listdiff obj …)
(define listdiff 
	(lambda (obj . args)
		(cons (cons obj args) '())))


(define length-ld-helper
	(lambda (listdiff len)
		(if (listdiff? listdiff)
      		(if (not (null-ld? listdiff))
           		(length-ld-helper (cdr-ld listdiff) (+ len 1))
           		len)
      	"error")))
 
(define length-ld 
	(lambda (listdiff)
		(length-ld-helper listdiff 0))) ;; put one more agrument to build tail recursive 

(define append-ld 
	(lambda (listdiff . args)
		(if (null? args) listdiff
      		(apply append-ld (cons (append (take (car listdiff) (length-ld listdiff)) (car (car args))) (cdr (car args))) 
           	(cdr args)))))

(define list-tail-ld
  (lambda (ld k)
    (let list-tail-ld-helper ([ld ld] [k k])
    	(cond 
    		[(eq? k 0) ld]
    		[(< k 0) "error"]
    		[else (list-tail-ld-helper (cdr-ld ld) (- k 1))]))))


;;(list->listdiff list)
(define list->listdiff
	(lambda (list)
		(if (list? list) (listdiff (car list) (cdr list)) 
		"error")))


;;(listdiff->list listdiff)
(define (listdiff->list listdiff)
  (if (null-ld? listdiff) '()
      (cons (car-ld listdiff) (listdiff->list (cdr-ld listdiff)))))


(define (expr-returning listdiff)
  (quasiquote (cons '(unquote (take (car listdiff) (length-ld listdiff))) '())))




