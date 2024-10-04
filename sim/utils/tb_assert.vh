// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 Anders <anders-code@users.noreply.github.com>

`ifndef UTILS_TB_ASSERT_VH
`define UTILS_TB_ASSERT_VH

`define tb_assert_import import tb_utils::*

`define tb_assert(a) \
    assert(a) tb_utils_asspass(`"a`", `__FILE__, `__LINE__); else \
              tb_utils_assfail(`"a`", `__FILE__, `__LINE__)
              
`define tb_assert_report tb_utils_report();

`endif // UTILS_TB_ASSERT_VH
