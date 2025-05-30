//===- CodeGenInstAlias.h - InstAlias Class Wrapper -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines a wrapper class for the 'InstAlias' TableGen class.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_UTILS_TABLEGEN_COMMON_CODEGENINSTALIAS_H
#define LLVM_UTILS_TABLEGEN_COMMON_CODEGENINSTALIAS_H

#include "llvm/ADT/StringRef.h"
#include <cassert>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace llvm {

template <typename T> class ArrayRef;
class CodeGenInstruction;
class CodeGenTarget;
class DagInit;
class SMLoc;
class Record;

/// CodeGenInstAlias - This represents an InstAlias definition.
class CodeGenInstAlias {
public:
  const Record *TheDef; // The actual record defining this InstAlias.

  /// AsmString - The format string used to emit a .s file for the
  /// instruction.
  std::string AsmString;

  /// Result - The result instruction.
  const DagInit *Result;

  /// ResultInst - The instruction generated by the alias (decoded from
  /// Result).
  CodeGenInstruction *ResultInst;

  struct ResultOperand {
  private:
    std::string Name;
    const Record *R = nullptr;
    int64_t Imm = 0;

  public:
    enum { K_Record, K_Imm, K_Reg } Kind;

    ResultOperand(std::string N, const Record *R)
        : Name(std::move(N)), R(R), Kind(K_Record) {}
    ResultOperand(int64_t I) : Imm(I), Kind(K_Imm) {}
    ResultOperand(const Record *R) : R(R), Kind(K_Reg) {}

    bool isRecord() const { return Kind == K_Record; }
    bool isImm() const { return Kind == K_Imm; }
    bool isReg() const { return Kind == K_Reg; }

    StringRef getName() const {
      assert(isRecord());
      return Name;
    }
    const Record *getRecord() const {
      assert(isRecord());
      return R;
    }
    int64_t getImm() const {
      assert(isImm());
      return Imm;
    }
    const Record *getRegister() const {
      assert(isReg());
      return R;
    }

    unsigned getMINumOperands() const;
  };

  /// ResultOperands - The decoded operands for the result instruction.
  std::vector<ResultOperand> ResultOperands;

  /// ResultInstOperandIndex - For each operand, this vector holds a pair of
  /// indices to identify the corresponding operand in the result
  /// instruction.  The first index specifies the operand and the second
  /// index specifies the suboperand.  If there are no suboperands or if all
  /// of them are matched by the operand, the second value should be -1.
  std::vector<std::pair<unsigned, int>> ResultInstOperandIndex;

  CodeGenInstAlias(const Record *R, const CodeGenTarget &T);

  bool tryAliasOpMatch(const DagInit *Result, unsigned AliasOpNo,
                       const Record *InstOpRec, bool hasSubOps,
                       ArrayRef<SMLoc> Loc, const CodeGenTarget &T,
                       ResultOperand &ResOp);
};

} // namespace llvm

#endif // LLVM_UTILS_TABLEGEN_COMMON_CODEGENINSTALIAS_H
