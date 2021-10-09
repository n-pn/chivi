<script context="module">
  export async function load({ stuff, fetch, page: { query } }) {
    const { cvbook } = stuff
    const [status, dboard] = await load_board(fetch, cvbook.id)
    if (!status) return { status, error: dboard }

    const page = +query.get('page') || 1
    const topics = await load_topics(fetch, dboard.id, page)
    return { props: { ...stuff, dboard, topics } }
  }

  async function load_board(fetch, id) {
    const url = `/api/boards/${id}`
    const res = await fetch(url)
    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  async function load_topics(fetch, board_id, page = 1, take = 15) {
    const url = `/api/topics?dboard=${board_i}&page=${page}&take=${take}`
    const res = await fetch(url)

    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  let form_title
  let form_tbody
  let form_error

  async function create_topic() {
    const params = { title: form_title, tbody: form_tbody }

    const url = `/api/boards/${dboard.id}/new`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (res.ok) console.log(await res.json())
    else form_error = await res.text()
  }
</script>

<script>
  import BookPage from './_layout/BookPage.svelte'
  export let cvbook
  export let ubmemo
  export let dboard
  export let topics

  let create_new = false
</script>

<BookPage {cvbook} {ubmemo} nvtab="discuss">
  <board-title>
    <board-stats>{dboard.posts} posts</board-stats>

    <board-action>
      <button class="m-btn _primary _fill" on:click={() => (create_new = false)}
        >Chủ đề mới</button>
    </board-action>
  </board-title>

  {#if create_new}
    <form action="/api/boards/{dboard.id}/new" on:submit={create_topic}>
      <label for="title">Tựa đề</label>
      <input type="text" name="title" bind:value={form_title} />

      <label for="tbody">Nội dung</label>
      <textarea name="title" bind:value={form_tbody} />

      {#if form_error}
        <form-error>{form_error}</form-error>
      {/if}

      <form-foot>
        <button
          type="cancel"
          class="m-btn  "
          on:click={() => (create_new = false)}>Huỷ bỏ</button>
        <button type="submit" class="m-btn _primary _fill"> Tạo chủ đề</button>
      </form-foot>
    </form>
  {:else}
    {#each topics.items as topic}
      <topic-card>
        {topic.title}
      </topic-card>
    {/each}
  {/if}
</BookPage>

<style lang="scss">
  .empty {
    min-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    color: var(--color-gray-5);
  }
</style>
