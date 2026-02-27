class_name GutTestHelper

static func coverage(script, gut_test: GutTest):
	var tests := []
	for i in ClassUtil.class_get_method_list(script, true).map(func(a): return a.name):
		if not gut_test.has_method("test_" + i):
			tests.append(i)
	if tests:
		gut_test.fail_test("uncovered test" + str(tests))
