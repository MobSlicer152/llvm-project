//===- PPCWinCOFFStreamer.h - WinCOFF Object Output -----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a custom MCWinCOFFStreamer for PowerPC.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_PPC_MCWinCOFFSTREAMER_PPCWinCOFFSTREAMER_H
#define LLVM_LIB_TARGET_PPC_MCWinCOFFSTREAMER_PPCWinCOFFSTREAMER_H

#include "llvm/MC/MCWinCOFFStreamer.h"

namespace llvm {

class PPCWinCOFFStreamer : public MCWinCOFFStreamer {
public:
  PPCWinCOFFStreamer(MCContext &Context, std::unique_ptr<MCAsmBackend> MAB,
                   std::unique_ptr<MCObjectWriter> OW,
                   std::unique_ptr<MCCodeEmitter> Emitter);

  void emitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI) override;

private:
  void emitPrefixedInstruction(const MCInst &Inst, const MCSubtargetInfo &STI);
};

MCStreamer *createPPCWinCOFFStreamer(MCContext &,
                                   std::unique_ptr<MCAsmBackend> &&MAB,
                                   std::unique_ptr<MCObjectWriter> &&OW,
                                   std::unique_ptr<MCCodeEmitter> &&Emitter);
} // end namespace llvm

#endif // LLVM_LIB_TARGET_PPC_MCWinCOFFSTREAMER_PPCWinCOFFSTREAMER_H
