//===- LoongArchFixupKinds.h - LoongArch Specific Fixup Entries -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_LOONGARCH_MCTARGETDESC_LOONGARCHFIXUPKINDS_H
#define LLVM_LIB_TARGET_LOONGARCH_MCTARGETDESC_LOONGARCHFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace LoongArch {
//
// This table *must* be in the same order of
// MCFixupKindInfo Infos[LoongArch::NumTargetFixupKinds] in
// LoongArchAsmBackend.cpp.
//
enum Fixups {
  // Define fixups can be handled by LoongArchAsmBackend::applyFixup.
  // 16-bit fixup corresponding to %b16(foo) for instructions like bne.
  fixup_loongarch_b16 = FirstTargetFixupKind,
  // 21-bit fixup corresponding to %b21(foo) for instructions like bnez.
  fixup_loongarch_b21,
  // 26-bit fixup corresponding to %b26(foo)/%plt(foo) for instructions b/bl.
  fixup_loongarch_b26,
  // 20-bit fixup corresponding to %abs_hi20(foo) for instruction lu12i.w.
  fixup_loongarch_abs_hi20,
  // 12-bit fixup corresponding to %abs_lo12(foo) for instruction ori.
  fixup_loongarch_abs_lo12,
  // 20-bit fixup corresponding to %abs64_lo20(foo) for instruction lu32i.d.
  fixup_loongarch_abs64_lo20,
  // 12-bit fixup corresponding to %abs_hi12(foo) for instruction lu52i.d.
  fixup_loongarch_abs64_hi12,

  // Used as a sentinel, must be the last of the fixup which can be handled by
  // LoongArchAsmBackend::applyFixup.
  fixup_loongarch_invalid,
  NumTargetFixupKinds = fixup_loongarch_invalid - FirstTargetFixupKind,
};
} // end namespace LoongArch
} // end namespace llvm

#endif
