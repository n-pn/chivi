const c = [
	() => import("..\\..\\..\\src\\routes\\__layout.svelte"),
	() => import("..\\..\\..\\src\\routes\\__error.svelte"),
	() => import("..\\..\\..\\src\\routes\\index.svelte"),
	() => import("..\\..\\..\\src\\routes\\search.svelte"),
	() => import("..\\..\\..\\src\\routes\\qtran.svelte"),
	() => import("..\\..\\..\\src\\routes\\@[user].svelte"),
	() => import("..\\..\\..\\src\\routes\\~[book]\\index.svelte"),
	() => import("..\\..\\..\\src\\routes\\~[book]\\content.svelte"),
	() => import("..\\..\\..\\src\\routes\\~[book]\\discuss.svelte"),
	() => import("..\\..\\..\\src\\routes\\~[book]\\+[seed].svelte"),
	() => import("..\\..\\..\\src\\routes\\~[book]\\-[chap].svelte")
];

const d = decodeURIComponent;

export const routes = [
	// src/routes/index.svelte
	[/^\/$/, [c[0], c[2]], [c[1]]],

	// src/routes/search.svelte
	[/^\/search\/?$/, [c[0], c[3]], [c[1]]],

	// src/routes/qtran.svelte
	[/^\/qtran\/?$/, [c[0], c[4]], [c[1]]],

	// src/routes/@[user].svelte
	[/^\/@([^/]+?)\/?$/, [c[0], c[5]], [c[1]], (m) => ({ user: d(m[1])})],

	// src/routes/~[book]/index.svelte
	[/^\/~([^/]+?)\/?$/, [c[0], c[6]], [c[1]], (m) => ({ book: d(m[1])})],

	// src/routes/~[book]/content.svelte
	[/^\/~([^/]+?)\/content\/?$/, [c[0], c[7]], [c[1]], (m) => ({ book: d(m[1])})],

	// src/routes/~[book]/discuss.svelte
	[/^\/~([^/]+?)\/discuss\/?$/, [c[0], c[8]], [c[1]], (m) => ({ book: d(m[1])})],

	// src/routes/~[book]/+[seed].svelte
	[/^\/~([^/]+?)\/\+([^/]+?)\/?$/, [c[0], c[9]], [c[1]], (m) => ({ book: d(m[1]), seed: d(m[2])})],

	// src/routes/~[book]/-[chap].svelte
	[/^\/~([^/]+?)\/-([^/]+?)\/?$/, [c[0], c[10]], [c[1]], (m) => ({ book: d(m[1]), chap: d(m[2])})]
];

export const fallback = [c[0](), c[1]()];