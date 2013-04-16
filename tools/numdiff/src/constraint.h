#ifndef CONSTRAINT_H
#define CONSTRAINT_H

/*
 o---------------------------------------------------------------------o
 |
 | Numdiff
 |
 | Copyright (c) 2012+ laurent.deniau@cern.ch
 | Gnu General Public License
 |
 o---------------------------------------------------------------------o
  
   Purpose:
     create constraints content
     print, scan constraints from file
 
 o---------------------------------------------------------------------o
*/

#include <stdio.h>
#include <string.h>
#include "slice.h"
#include "error.h"

// ----- constants

enum eps_cmd {
  eps_invalid = 0u,       // invalid command

// must be firsts (constrains)
  eps_abs    = 1u <<  0,  // absolute eps
  eps_rel    = 1u <<  1,  // relative eps
  eps_dig    = 1u <<  2,  // relative input eps
  eps_equ    = 1u <<  3,  // equal string
  eps_ign    = 1u <<  4,  // ignore value
  eps_istr   = 1u <<  5,  // ignore strings

// intermediate (commands & qualifiers)
  eps_any    = 1u <<  6,  // any qualifier
  eps_llhs   = 1u <<  7,  // load reg in x
  eps_lrhs   = 1u <<  8,  // load reg in y
  eps_slhs   = 1u <<  9,  // save x in reg
  eps_srhs   = 1u << 10,  // save y in reg
  eps_move   = 1u << 11,  // copy register(s)
  eps_omit   = 1u << 12,  // omit qualifier
  eps_trace  = 1u << 13,  // trace qualifier

// must be lasts (actions)
  eps_skip   = 1u << 14,  // skip line, must be first action!!
  eps_goto   = 1u << 15,  // go to tag
  eps_gonum  = 1u << 16,  // go to number

// marker & mask
  eps_last   = 1u << 17,  // the end
  eps_mask   = eps_last - 1,

// non-persistent commands & qualifiers
  eps_large  = eps_last << 0,  // large tolerance

// unions
  eps_dra    =  eps_abs  | eps_rel  | eps_dig,
  eps_sgg    =  eps_skip | eps_goto | eps_gonum,
};

// ----- types

struct eps {
  enum eps_cmd cmd;

  double  scl;
  double  abs,  rel,  dig;
  double _abs, _rel, _dig;

  char    scl_reg,  gto_reg;
  char    abs_reg,  rel_reg,  dig_reg;
  char   _abs_reg, _rel_reg, _dig_reg;

  char    slhs_reg, srhs_reg;
  char    llhs_reg, lrhs_reg;
  char    src_reg[5], dst_reg[5], cnt_reg[5], n_reg;

  char    tag[64];
};

struct constraint {
  struct slice row;
  struct slice col;
  struct eps   eps;
  int    idx, line;
};

// ----- interface

#define T struct constraint

static inline struct eps
eps_initAllNum(enum eps_cmd cmd, double abs, double rel, double dig, double _abs, double _rel, double _dig, double scl)
{
  ensure(cmd > eps_invalid && cmd < eps_last, "invalid eps command");
  return (struct eps) { .cmd=cmd, .abs=abs, .rel=rel, .dig=dig, ._abs=_abs, ._rel=_rel, ._dig=_dig, .scl=scl };
}

static inline struct eps
eps_initNum(enum eps_cmd cmd, double abs, double rel, double dig, double scl)
{
  return eps_initAllNum(cmd, abs, rel, dig, -abs, -rel, -dig, scl);
}

static inline struct eps
eps_init(enum eps_cmd cmd, double val)
{
  return eps_initNum(cmd, cmd&eps_abs?val:0, cmd&eps_rel?val:0, cmd&eps_dig?val:0, 1.0);
}

static inline struct eps
eps_initStrTag(enum eps_cmd cmd, const char *tag)
{
  ensure((cmd & eps_goto) || (cmd & eps_omit), "invalid eps goto or omit command");
  struct eps eps = (struct eps) { .cmd=cmd };
  enum { sz = sizeof eps.tag };
  strncpy(eps.tag, tag, sz); eps.tag[sz-1] = 0;
  return eps;
}

static inline struct eps
eps_initNumTag(enum eps_cmd cmd, const char *tag)
{
  char *end;
  strtod(tag, &end);
  ensure((cmd & eps_gonum) && !*end, "invalid eps goto command");
  struct eps eps = (struct eps) { .cmd=cmd };
  enum { sz = sizeof eps.tag };
  strncpy(eps.tag, tag, sz); eps.tag[sz-1] = 0;
  return eps;
}

static inline T
constraint_init(const struct slice row, const struct slice col, const struct eps eps, int idx, int line)
{
  bool allcol = eps.cmd & eps_skip || eps.cmd & eps_goto;
  return (T){ row, allcol ? slice_initAll() : col, eps, idx, line };
}

void constraint_print(const T* cst, FILE *out);
void constraint_scan (      T* cst, FILE *in, int *row);

#undef T

#endif

