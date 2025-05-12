//===-- PPCWinCOFFObjectWriter.cpp - PPC Win COFF Writer ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/PPCFixupKinds.h"
#include "MCTargetDesc/PPCMCExpr.h"
#include "MCTargetDesc/PPCMCTargetDesc.h"
#include "llvm/BinaryFormat/COFF.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/MCWinCOFFObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {

class PPCWinCOFFObjectWriter : public MCWinCOFFObjectTargetWriter {
public:
  PPCWinCOFFObjectWriter(bool Is64Bit);
  ~PPCWinCOFFObjectWriter() override = default;

  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsCrossSection,
                        const MCAsmBackend &MAB) const override;
};

} // end anonymous namespace

PPCWinCOFFObjectWriter::PPCWinCOFFObjectWriter(bool Is64Bit)
    : MCWinCOFFObjectTargetWriter(COFF::IMAGE_FILE_MACHINE_POWERPCBE) {}

unsigned PPCWinCOFFObjectWriter::getRelocType(MCContext &Ctx,
                                              const MCValue &Target,
                                              const MCFixup &Fixup,
                                              bool IsCrossSection,
                                              const MCAsmBackend &MAB) const {
  auto Specifier = Target.getSpecifier();
  unsigned Kind = Fixup.getKind();

  switch (Kind) {
  default:
    Ctx.reportError(Fixup.getLoc(), "Unimplemented fixup kind.");
    return COFF::IMAGE_REL_PPC_ABSOLUTE;

  case PPC::fixup_ppc_half16:
    switch (Specifier) {
    case PPCMCExpr::VK_None:
      return COFF::IMAGE_REL_PPC_TOCREL16;
    case PPCMCExpr::VK_U:
      return COFF::IMAGE_REL_PPC_REFHI;
    case PPCMCExpr::VK_L:
      return COFF::IMAGE_REL_PPC_REFLO;
    case PPCMCExpr::VK_AIX_TLSLE:
    case PPCMCExpr::VK_AIX_TLSLD:
      return COFF::IMAGE_REL_PPC_GPREL; // Approximate guess
    default:
      //Ctx.reportError(Fixup.getLoc(), Twine("Unsupported modifier for half16: ").concat(std::to_string(Specifier)));
      return COFF::IMAGE_REL_PPC_ABSOLUTE;
    }

  case PPC::fixup_ppc_half16ds:
  case PPC::fixup_ppc_half16dq:
    switch (Specifier) {
    case PPCMCExpr::VK_None:
      return COFF::IMAGE_REL_PPC_TOCREL16;
    case PPCMCExpr::VK_L:
      return COFF::IMAGE_REL_PPC_REFLO;
    case PPCMCExpr::VK_AIX_TLSLE:
    case PPCMCExpr::VK_AIX_TLSLD:
      return COFF::IMAGE_REL_PPC_GPREL;
    default:
      llvm_unreachable("Unsupported Modifier");
    }

  case PPC::fixup_ppc_br24:
    return COFF::IMAGE_REL_PPC_REL24;

  case PPC::fixup_ppc_br24abs:
    return COFF::IMAGE_REL_PPC_ADDR24;

  case PPC::fixup_ppc_nofixup:
    if (Specifier == PPCMCExpr::VK_None)
      return COFF::IMAGE_REL_PPC_ABSOLUTE;
    llvm_unreachable("Unsupported Modifier");

  case FK_Data_4:
    switch (Specifier) {
    case PPCMCExpr::VK_None:
      return COFF::IMAGE_REL_PPC_ADDR32;
    case PPCMCExpr::VK_AIX_TLSGD:
    case PPCMCExpr::VK_AIX_TLSGDM:
    case PPCMCExpr::VK_AIX_TLSIE:
    case PPCMCExpr::VK_AIX_TLSLE:
    case PPCMCExpr::VK_AIX_TLSLD:
    case PPCMCExpr::VK_AIX_TLSML:
      return COFF::IMAGE_REL_PPC_GPREL; // Best approximation
    default:
      Ctx.reportError(Fixup.getLoc(), "Unsupported modifier");
      return COFF::IMAGE_REL_PPC_ABSOLUTE;
    }

  case FK_Data_8:
    return COFF::IMAGE_REL_PPC_ADDR64;
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createPPCWinCOFFObjectWriter(bool Is64Bit) {
  return std::make_unique<PPCWinCOFFObjectWriter>(Is64Bit);
}
