<script context="module">
  export async function preload({ params }) {
    const slug = params.book

    const url = `api/books/${slug}`
    console.log(encodeURI(url))

    const res = await this.fetch(url)
    const data = await res.json()

    if (!!data.entry) {
      return data
    } else {
      this.error(404, 'Book not found!')
    }
  }
</script>

<script>
  export let entry
  export let chaps = []
</script>

<svelte:head>
  <title>{entry.vi_title} -- Chivi</title>
</svelte:head>

<div class="list">
  {#each chaps as chap}
    <div class="chap">

      <a class="chap-link" href="/{entry.vi_slug}/{chap.uid}-{chap.url_slug}">
        {chap.vi_title}
      </a>

    </div>
  {/each}

</div>
