; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-annotate-decl-cs  -S < %s | FileCheck %s --check-prefixes=CHECK,TUNIT
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"

declare ptr @geti1Ptr()

; Make sure we do *not* return true.
;.
; CHECK: @G1 = private global ptr undef
; CHECK: @G2 = private global ptr undef
; CHECK: @G3 = private global i1 undef
;.
define internal i1 @recursive_inst_comparator(ptr %a, ptr %b) {
; CHECK: Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
; CHECK-LABEL: define {{[^@]+}}@recursive_inst_comparator
; CHECK-SAME: (ptr noalias nofree readnone [[A:%.*]], ptr noalias nofree readnone [[B:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[B]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %cmp = icmp eq ptr %a, %b
  ret i1 %cmp
}

define internal i1 @recursive_inst_generator(i1 %c, ptr %p) {
; TUNIT-LABEL: define {{[^@]+}}@recursive_inst_generator
; TUNIT-SAME: (i1 [[C:%.*]], ptr nofree [[P:%.*]]) {
; TUNIT-NEXT:    [[A:%.*]] = call ptr @geti1Ptr()
; TUNIT-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; TUNIT:       t:
; TUNIT-NEXT:    [[R1:%.*]] = call i1 @recursive_inst_comparator(ptr noalias nofree readnone [[A]], ptr noalias nofree readnone [[P]]) #[[ATTR7:[0-9]+]]
; TUNIT-NEXT:    ret i1 [[R1]]
; TUNIT:       f:
; TUNIT-NEXT:    [[R2:%.*]] = call i1 @recursive_inst_generator(i1 noundef true, ptr nofree [[A]])
; TUNIT-NEXT:    ret i1 [[R2]]
;
; CGSCC-LABEL: define {{[^@]+}}@recursive_inst_generator
; CGSCC-SAME: (i1 [[C:%.*]], ptr nofree [[P:%.*]]) {
; CGSCC-NEXT:    [[A:%.*]] = call ptr @geti1Ptr()
; CGSCC-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CGSCC:       t:
; CGSCC-NEXT:    [[R1:%.*]] = call i1 @recursive_inst_comparator(ptr noalias nofree readnone [[A]], ptr noalias nofree readnone [[P]])
; CGSCC-NEXT:    ret i1 [[R1]]
; CGSCC:       f:
; CGSCC-NEXT:    [[R2:%.*]] = call i1 @recursive_inst_generator(i1 noundef true, ptr nofree [[A]])
; CGSCC-NEXT:    ret i1 [[R2]]
;
  %a = call ptr @geti1Ptr()
  br i1 %c, label %t, label %f
t:
  %r1 = call i1 @recursive_inst_comparator(ptr %a, ptr %p)
  ret i1 %r1
f:
  %r2 = call i1 @recursive_inst_generator(i1 true, ptr %a)
  ret i1 %r2
}

; FIXME: This should *not* return true.
define i1 @recursive_inst_generator_caller(i1 %c) {
; TUNIT-LABEL: define {{[^@]+}}@recursive_inst_generator_caller
; TUNIT-SAME: (i1 [[C:%.*]]) {
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_generator(i1 [[C]], ptr undef)
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC-LABEL: define {{[^@]+}}@recursive_inst_generator_caller
; CGSCC-SAME: (i1 [[C:%.*]]) {
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_generator(i1 [[C]], ptr nofree undef)
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_inst_generator(i1 %c, ptr undef)
  ret i1 %call
}

; Make sure we do *not* return true.
define internal i1 @recursive_inst_compare(i1 %c, ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@recursive_inst_compare
; CHECK-SAME: (i1 [[C:%.*]], ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = call ptr @geti1Ptr()
; CHECK-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CHECK:       t:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; CHECK-NEXT:    ret i1 [[CMP]]
; CHECK:       f:
; CHECK-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare(i1 noundef true, ptr [[A]])
; CHECK-NEXT:    ret i1 [[CALL]]
;
  %a = call ptr @geti1Ptr()
  br i1 %c, label %t, label %f
t:
  %cmp = icmp eq ptr %a, %p
  ret i1 %cmp
f:
  %call = call i1 @recursive_inst_compare(i1 true, ptr %a)
  ret i1 %call
}

; FIXME: This should *not* return true.
define i1 @recursive_inst_compare_caller(i1 %c) {
; CHECK-LABEL: define {{[^@]+}}@recursive_inst_compare_caller
; CHECK-SAME: (i1 [[C:%.*]]) {
; CHECK-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare(i1 [[C]], ptr undef)
; CHECK-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_inst_compare(i1 %c, ptr undef)
  ret i1 %call
}

; Make sure we do *not* return true.
define internal i1 @recursive_alloca_compare(i1 %c, ptr %p) {
; CHECK: Function Attrs: nofree nosync nounwind memory(none)
; CHECK-LABEL: define {{[^@]+}}@recursive_alloca_compare
; CHECK-SAME: (i1 noundef [[C:%.*]], ptr noalias nofree readnone [[P:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    [[A:%.*]] = alloca i1, align 1
; CHECK-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CHECK:       t:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; CHECK-NEXT:    ret i1 [[CMP]]
; CHECK:       f:
; CHECK-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare(i1 noundef true, ptr noalias nofree noundef nonnull readnone dereferenceable(1) [[A]]) #[[ATTR1]]
; CHECK-NEXT:    ret i1 [[CALL]]
;
  %a = alloca i1
  br i1 %c, label %t, label %f
t:
  %cmp = icmp eq ptr %a, %p
  ret i1 %cmp
f:
  %call = call i1 @recursive_alloca_compare(i1 true, ptr %a)
  ret i1 %call
}

; FIXME: This should *not* return true.
define i1 @recursive_alloca_compare_caller(i1 %c) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind memory(none)
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR2:[0-9]+]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare(i1 noundef [[C]], ptr undef) #[[ATTR1]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind memory(none)
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare(i1 noundef [[C]], ptr nofree undef) #[[ATTR1]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_alloca_compare(i1 %c, ptr undef)
  ret i1 %call
}

; Make sure we do *not* simplify this to return 0 or 1, return 42 is ok though.
define internal i8 @recursive_alloca_load_return(i1 %c, ptr %p, i8 %v) {
; TUNIT: Function Attrs: nofree nosync nounwind memory(argmem: readwrite)
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_load_return
; TUNIT-SAME: (i1 noundef [[C:%.*]], ptr noalias nofree readonly captures(none) [[P:%.*]], i8 noundef [[V:%.*]]) #[[ATTR3:[0-9]+]] {
; TUNIT-NEXT:    [[A:%.*]] = alloca i8, align 1
; TUNIT-NEXT:    store i8 [[V]], ptr [[A]], align 1
; TUNIT-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; TUNIT:       t:
; TUNIT-NEXT:    store i8 0, ptr [[A]], align 1
; TUNIT-NEXT:    [[L:%.*]] = load i8, ptr [[P]], align 1
; TUNIT-NEXT:    ret i8 [[L]]
; TUNIT:       f:
; TUNIT-NEXT:    [[CALL:%.*]] = call i8 @recursive_alloca_load_return(i1 noundef true, ptr noalias nofree noundef nonnull readonly captures(none) dereferenceable(1) [[A]], i8 noundef 1) #[[ATTR4:[0-9]+]]
; TUNIT-NEXT:    ret i8 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind memory(argmem: readwrite)
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_load_return
; CGSCC-SAME: (i1 noundef [[C:%.*]], ptr noalias nofree readonly captures(none) [[P:%.*]], i8 noundef [[V:%.*]]) #[[ATTR2:[0-9]+]] {
; CGSCC-NEXT:    [[A:%.*]] = alloca i8, align 1
; CGSCC-NEXT:    store i8 [[V]], ptr [[A]], align 1
; CGSCC-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CGSCC:       t:
; CGSCC-NEXT:    store i8 0, ptr [[A]], align 1
; CGSCC-NEXT:    [[L:%.*]] = load i8, ptr [[P]], align 1
; CGSCC-NEXT:    ret i8 [[L]]
; CGSCC:       f:
; CGSCC-NEXT:    [[CALL:%.*]] = call i8 @recursive_alloca_load_return(i1 noundef true, ptr noalias nofree noundef nonnull readonly captures(none) dereferenceable(1) [[A]], i8 noundef 1) #[[ATTR3:[0-9]+]]
; CGSCC-NEXT:    ret i8 [[CALL]]
;
  %a = alloca i8
  store i8 %v, ptr %a
  br i1 %c, label %t, label %f
t:
  store i8 0, ptr %a
  %l = load i8, ptr %p
  ret i8 %l
f:
  %call = call i8 @recursive_alloca_load_return(i1 true, ptr %a, i8 1)
  ret i8 %call
}

define i8 @recursive_alloca_load_return_caller(i1 %c) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind memory(none)
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_load_return_caller
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR2]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i8 @recursive_alloca_load_return(i1 noundef [[C]], ptr undef, i8 noundef 42) #[[ATTR4]]
; TUNIT-NEXT:    ret i8 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind memory(none)
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_load_return_caller
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i8 @recursive_alloca_load_return(i1 noundef [[C]], ptr nofree undef, i8 noundef 42) #[[ATTR5:[0-9]+]]
; CGSCC-NEXT:    ret i8 [[CALL]]
;
  %call = call i8 @recursive_alloca_load_return(i1 %c, ptr undef, i8 42)
  ret i8 %call
}

@G1 = private global ptr undef
@G2 = private global ptr undef
@G3 = private global i1 undef

; Make sure we do *not* return true.
define internal i1 @recursive_alloca_compare_global1(i1 %c) {
; TUNIT: Function Attrs: nofree nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_compare_global1
; TUNIT-SAME: (i1 noundef [[C:%.*]]) #[[ATTR4]] {
; TUNIT-NEXT:    [[A:%.*]] = alloca i1, align 1
; TUNIT-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; TUNIT:       t:
; TUNIT-NEXT:    [[P:%.*]] = load ptr, ptr @G1, align 8
; TUNIT-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; TUNIT-NEXT:    ret i1 [[CMP]]
; TUNIT:       f:
; TUNIT-NEXT:    store ptr [[A]], ptr @G1, align 8
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global1(i1 noundef true) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_compare_global1
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[A:%.*]] = alloca i1, align 1
; CGSCC-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CGSCC:       t:
; CGSCC-NEXT:    [[P:%.*]] = load ptr, ptr @G1, align 8
; CGSCC-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; CGSCC-NEXT:    ret i1 [[CMP]]
; CGSCC:       f:
; CGSCC-NEXT:    store ptr [[A]], ptr @G1, align 8
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global1(i1 noundef true) #[[ATTR3]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %a = alloca i1
  br i1 %c, label %t, label %f
t:
  %p = load ptr, ptr @G1
  %cmp = icmp eq ptr %a, %p
  ret i1 %cmp
f:
  store ptr %a, ptr @G1
  %call = call i1 @recursive_alloca_compare_global1(i1 true)
  ret i1 %call
}

; FIXME: This should *not* return true.
define i1 @recursive_alloca_compare_caller_global1(i1 %c) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller_global1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR5:[0-9]+]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global1(i1 noundef [[C]]) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller_global1
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global1(i1 noundef [[C]]) #[[ATTR5]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_alloca_compare_global1(i1 %c)
  ret i1 %call
}

define internal i1 @recursive_alloca_compare_global2(i1 %c) {
; TUNIT: Function Attrs: nofree nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_compare_global2
; TUNIT-SAME: (i1 noundef [[C:%.*]]) #[[ATTR4]] {
; TUNIT-NEXT:    [[A:%.*]] = alloca i1, align 1
; TUNIT-NEXT:    [[P:%.*]] = load ptr, ptr @G2, align 8
; TUNIT-NEXT:    store ptr [[A]], ptr @G2, align 8
; TUNIT-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; TUNIT:       t:
; TUNIT-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; TUNIT-NEXT:    ret i1 [[CMP]]
; TUNIT:       f:
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global2(i1 noundef true) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_compare_global2
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[A:%.*]] = alloca i1, align 1
; CGSCC-NEXT:    [[P:%.*]] = load ptr, ptr @G2, align 8
; CGSCC-NEXT:    store ptr [[A]], ptr @G2, align 8
; CGSCC-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CGSCC:       t:
; CGSCC-NEXT:    [[CMP:%.*]] = icmp eq ptr [[A]], [[P]]
; CGSCC-NEXT:    ret i1 [[CMP]]
; CGSCC:       f:
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global2(i1 noundef true) #[[ATTR3]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %a = alloca i1
  %p = load ptr, ptr @G2
  store ptr %a, ptr @G2
  br i1 %c, label %t, label %f
t:
  %cmp = icmp eq ptr %a, %p
  ret i1 %cmp
f:
  %call = call i1 @recursive_alloca_compare_global2(i1 true)
  ret i1 %call
}

; FIXME: This should *not* return true.
define i1 @recursive_alloca_compare_caller_global2(i1 %c) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller_global2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR5]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global2(i1 noundef [[C]]) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_alloca_compare_caller_global2
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_alloca_compare_global2(i1 noundef [[C]]) #[[ATTR5]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_alloca_compare_global2(i1 %c)
  ret i1 %call
}
define internal i1 @recursive_inst_compare_global3(i1 %c) {
;
; TUNIT: Function Attrs: nofree nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_inst_compare_global3
; TUNIT-SAME: (i1 noundef [[C:%.*]]) #[[ATTR4]] {
; TUNIT-NEXT:    [[P:%.*]] = load i1, ptr @G3, align 1
; TUNIT-NEXT:    store i1 [[C]], ptr @G3, align 1
; TUNIT-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; TUNIT:       t:
; TUNIT-NEXT:    [[CMP:%.*]] = icmp eq i1 [[C]], [[P]]
; TUNIT-NEXT:    ret i1 [[CMP]]
; TUNIT:       f:
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare_global3(i1 noundef true) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_inst_compare_global3
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[P:%.*]] = load i1, ptr @G3, align 1
; CGSCC-NEXT:    store i1 [[C]], ptr @G3, align 1
; CGSCC-NEXT:    br i1 [[C]], label [[T:%.*]], label [[F:%.*]]
; CGSCC:       t:
; CGSCC-NEXT:    [[CMP:%.*]] = icmp eq i1 [[C]], [[P]]
; CGSCC-NEXT:    ret i1 [[CMP]]
; CGSCC:       f:
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare_global3(i1 noundef true) #[[ATTR3]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %p = load i1, ptr @G3
  store i1 %c, ptr @G3
  br i1 %c, label %t, label %f
t:
  %cmp = icmp eq i1 %c, %p
  ret i1 %cmp
f:
  %call = call i1 @recursive_inst_compare_global3(i1 true)
  ret i1 %call
}

; FIXME: This should *not* return true.
define i1 @recursive_inst_compare_caller_global3(i1 %c) {
; TUNIT: Function Attrs: nofree norecurse nosync nounwind
; TUNIT-LABEL: define {{[^@]+}}@recursive_inst_compare_caller_global3
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR5]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare_global3(i1 noundef [[C]]) #[[ATTR4]]
; TUNIT-NEXT:    ret i1 [[CALL]]
;
; CGSCC: Function Attrs: nofree nosync nounwind
; CGSCC-LABEL: define {{[^@]+}}@recursive_inst_compare_caller_global3
; CGSCC-SAME: (i1 noundef [[C:%.*]]) #[[ATTR3]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i1 @recursive_inst_compare_global3(i1 noundef [[C]]) #[[ATTR5]]
; CGSCC-NEXT:    ret i1 [[CALL]]
;
  %call = call i1 @recursive_inst_compare_global3(i1 %c)
  ret i1 %call
}

define i32 @non_unique_phi_ops(ptr %ptr) {
; TUNIT: Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
; TUNIT-LABEL: define {{[^@]+}}@non_unique_phi_ops
; TUNIT-SAME: (ptr nofree readonly captures(none) [[PTR:%.*]]) #[[ATTR6:[0-9]+]] {
; TUNIT-NEXT:  entry:
; TUNIT-NEXT:    br label [[HEADER:%.*]]
; TUNIT:       header:
; TUNIT-NEXT:    [[I:%.*]] = phi i32 [ [[ADD:%.*]], [[F:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; TUNIT-NEXT:    [[P:%.*]] = phi i32 [ [[NON_UNIQUE:%.*]], [[F]] ], [ poison, [[ENTRY]] ]
; TUNIT-NEXT:    [[ADD]] = add i32 [[I]], 1
; TUNIT-NEXT:    [[G:%.*]] = getelementptr i32, ptr [[PTR]], i32 [[I]]
; TUNIT-NEXT:    [[NON_UNIQUE_INPUT:%.*]] = load i32, ptr [[G]], align 4
; TUNIT-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[I]], [[NON_UNIQUE_INPUT]]
; TUNIT-NEXT:    br i1 [[CMP1]], label [[T:%.*]], label [[F]]
; TUNIT:       t:
; TUNIT-NEXT:    br label [[F]]
; TUNIT:       f:
; TUNIT-NEXT:    [[NON_UNIQUE]] = phi i32 [ [[NON_UNIQUE_INPUT]], [[T]] ], [ [[P]], [[HEADER]] ]
; TUNIT-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 42
; TUNIT-NEXT:    br i1 [[CMP2]], label [[HEADER]], label [[END:%.*]]
; TUNIT:       end:
; TUNIT-NEXT:    ret i32 [[P]]
;
; CGSCC: Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
; CGSCC-LABEL: define {{[^@]+}}@non_unique_phi_ops
; CGSCC-SAME: (ptr nofree readonly captures(none) [[PTR:%.*]]) #[[ATTR4:[0-9]+]] {
; CGSCC-NEXT:  entry:
; CGSCC-NEXT:    br label [[HEADER:%.*]]
; CGSCC:       header:
; CGSCC-NEXT:    [[I:%.*]] = phi i32 [ [[ADD:%.*]], [[F:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; CGSCC-NEXT:    [[P:%.*]] = phi i32 [ [[NON_UNIQUE:%.*]], [[F]] ], [ poison, [[ENTRY]] ]
; CGSCC-NEXT:    [[ADD]] = add i32 [[I]], 1
; CGSCC-NEXT:    [[G:%.*]] = getelementptr i32, ptr [[PTR]], i32 [[I]]
; CGSCC-NEXT:    [[NON_UNIQUE_INPUT:%.*]] = load i32, ptr [[G]], align 4
; CGSCC-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[I]], [[NON_UNIQUE_INPUT]]
; CGSCC-NEXT:    br i1 [[CMP1]], label [[T:%.*]], label [[F]]
; CGSCC:       t:
; CGSCC-NEXT:    br label [[F]]
; CGSCC:       f:
; CGSCC-NEXT:    [[NON_UNIQUE]] = phi i32 [ [[NON_UNIQUE_INPUT]], [[T]] ], [ [[P]], [[HEADER]] ]
; CGSCC-NEXT:    [[CMP2:%.*]] = icmp slt i32 [[I]], 42
; CGSCC-NEXT:    br i1 [[CMP2]], label [[HEADER]], label [[END:%.*]]
; CGSCC:       end:
; CGSCC-NEXT:    ret i32 [[P]]
;
entry:
  br label %header

header:
  %i = phi i32 [ %add, %f ], [ 0, %entry ]
  %p = phi i32 [ %non_unique, %f ], [ poison, %entry ]
  %add = add i32 %i, 1
  %g = getelementptr i32, ptr %ptr, i32 %i
  %non_unique_input = load i32, ptr %g, align 4
  %cmp1 = icmp eq i32 %i, %non_unique_input
  br i1 %cmp1, label %t, label %f
t:
  br label %f
f:
  %non_unique = phi i32 [ %non_unique_input, %t ], [ %p, %header ]
  %cmp2 = icmp slt i32 %i, 42
  br i1 %cmp2, label %header, label %end

end:
  ret i32 %p
}

;.
; TUNIT: attributes #[[ATTR0]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) }
; TUNIT: attributes #[[ATTR1]] = { nofree nosync nounwind memory(none) }
; TUNIT: attributes #[[ATTR2]] = { nofree norecurse nosync nounwind memory(none) }
; TUNIT: attributes #[[ATTR3]] = { nofree nosync nounwind memory(argmem: readwrite) }
; TUNIT: attributes #[[ATTR4]] = { nofree nosync nounwind }
; TUNIT: attributes #[[ATTR5]] = { nofree norecurse nosync nounwind }
; TUNIT: attributes #[[ATTR6]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) }
; TUNIT: attributes #[[ATTR7]] = { nounwind memory(none) }
;.
; CGSCC: attributes #[[ATTR0]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) }
; CGSCC: attributes #[[ATTR1]] = { nofree nosync nounwind memory(none) }
; CGSCC: attributes #[[ATTR2]] = { nofree nosync nounwind memory(argmem: readwrite) }
; CGSCC: attributes #[[ATTR3]] = { nofree nosync nounwind }
; CGSCC: attributes #[[ATTR4]] = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) }
; CGSCC: attributes #[[ATTR5]] = { nofree nounwind }
;.
