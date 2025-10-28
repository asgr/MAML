test_that("UCDWords methods behave correctly", {
    ucd <- UCDWords$new()

    # is_primary / is_secondary
    expect_true(ucd$is_primary("arith"))
    expect_true(ucd$is_secondary("arith"))
    expect_true(ucd$is_secondary("arith.diff"))
    expect_true(ucd$is_primary("arith.factor"))
    expect_false(ucd$is_primary("arith.diff"))
    expect_false(ucd$is_secondary("arith.factor"))

    # get_description
    desc <- ucd$get_description("em.IR.H")
    expect_true(is.character(desc))
    expect_match(desc, "Infrared", ignore.case = TRUE)

    # normalize_capitalization
    expect_equal(
        ucd$normalize_capitalization("em.ir.h"),
        "em.IR.H"
    )

    # check_ucd
    valid_ucd <- "arith;em.IR.H"
    not_valid1 <- "em.IR.H"
    valid_case_insensitive <- "arItH;EM.IR.H"
    not_valid_order <- "em.IR.H;arith"
    not_valid_random <- "arith;foobar"
    not_valid_random_2 <- "foobar;em.IR.H"

    expect_true(ucd$check_ucd(valid_ucd))
    expect_false(ucd$check_ucd(not_valid1))
    expect_true(ucd$check_ucd(valid_case_insensitive))
    expect_false(ucd$check_ucd(not_valid_order))
    expect_false(ucd$check_ucd(not_valid_random))
    expect_false(ucd$check_ucd(not_valid_random_2))
})
