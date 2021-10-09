<script context="module">
  export async function load({ stuff, fetch, page: { query } }) {
    const { cvbook } = stuff
    const [status, dboard] = await load_board(fetch, cvbook.id)

    if (status) return { status, error: dboard }

    const page = +query.get('page') || 1
    const [status_2, dtopic] = await load_topics(fetch, cvbook.id, page)
    if (status_2) return { status: status_2, error: dtopic }

    return { props: { ...stuff, dboard, dtopic } }
  }

  async function load_board(fetch, id) {
    const url = `/api/boards/${id}`
    const res = await fetch(url)
    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  async function load_topics(fetch, board_id, page = 1, take = 15) {
    const url = `/api/boards/${board_id}/topics?page=${page}&take=${take}`
    const res = await fetch(url)

    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }
</script>

<script>
  import { invalidate } from '$app/navigation'
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let cvbook
  export let ubmemo
  export let dboard
  export let dtopic = { items: [] }

  let create_new = false
  let form_title = 'ha ha ha xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  let form_error

  async function create_topic() {
    const url = `/api/boards/${cvbook.id}/new`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: form_title }),
    })

    if (res.ok) console.log(await res.json())
    else form_error = await res.text()

    create_new = false
    invalidate(`/api/boards/${cvbook.id}/topics`)
  }
</script>

<BookPage {cvbook} {ubmemo} nvtab="board">
  <board-content>
    <board-title>
      <board-stats>{dboard.posts} posts</board-stats>

      <board-action>
        <button
          class="m-button _primary _fill"
          on:click={() => (create_new = true)}>Chủ đề mới</button>
      </board-action>
    </board-title>

    {#if create_new}
      <form
        action="/api/boards/{cvbook.id}/new"
        on:submit|preventDefault={create_topic}
        method="POST">
        <form-field>
          <label class="form-label" for="title">Tựa đề</label>
          <textarea
            class="m-input"
            name="title"
            rows="2"
            lang="vi"
            bind:value={form_title} />
        </form-field>

        {#if form_error}
          <form-error>{form_error}</form-error>
        {/if}

        <form-foot>
          <button
            type="cancel"
            class="m-button"
            on:click={() => (create_new = false)}>Huỷ bỏ</button>
          <button
            type="submit"
            class="m-button _primary _fill"
            on:click|preventDefault={create_topic}>
            Tạo chủ đề</button>
        </form-foot>
      </form>
    {:else}
      {#each dtopic.items as topic}
        <topic-card>
          <topic-body>
            <a
              class="topic-title"
              href="/-{cvbook.bslug}/board/-{topic.uslug}-{topic.id}">
              {topic.title}
            </a>

            <a class="topic-label" href=".?tl=1">Thảo luận</a>
            <a class="topic-label" href=".?tl=2">Dịch thuật</a>
          </topic-body>

          <topic-foot>
            <topic-user>{topic.u_dname}</topic-user>
            <topic-sep>·</topic-sep>
            <topic-time>{get_rtime(topic.ctime || 1212121200)}</topic-time>
            <topic-sep>·</topic-sep>
            <topic-repl>
              {#if topic.posts > 0}
                <span>{topic.posts} lượt trả lời</span>
              {:else}
                <span>Trả lời</span>
              {/if}
            </topic-repl>
          </topic-foot>
        </topic-card>
      {:else}
        <div class="empty">Chưa có chủ đề thảo luận :(</div>
      {/each}
    {/if}
  </board-content>
</BookPage>

<style lang="scss">
  board-content {
    display: block;
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

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

  form-field {
    display: block;
  }

  .form-label {
    display: block;
    line-height: 1.75rem;
    font-weight: 500;
    margin-top: 0.25rem;
    @include fgcolor(secd);
  }

  form-foot {
    @include flex($gap: 0.5rem);
    margin-top: 0.75rem;
    justify-content: right;
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 4rem;
    max-height: 10rem;
    font-weight: 500;

    @include ftsize(lg);
    @include fgcolor(secd);
  }

  topic-card {
    display: block;

    @include border(--bd-main, $loc: bottom);
    &:first-of-type {
      @include border(--bd-main, $loc: top);
    }

    > * {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  topic-foot {
    @include flex($gap: 0.25rem);
    line-height: 2rem;
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-user {
    font-weight: 500;
    // @include ftsize(md);
  }

  topic-body {
    display: block;
    padding-top: 0.5rem;

    @include bps(font-size, rem(16px), rem(17px));

    cursor: pointer;
    &:hover .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  .topic-title {
    @include ftsize(lg);
    @include fgcolor(secd);
    font-weight: 500;
    line-height: 1.5rem;
  }

  .topic-label {
    display: inline-block;
    line-height: 1.5rem;
    padding: 0 0.375rem;
    font-weight: 500;

    @include bdradi();
    @include ftsize(sm);

    @include fgcolor(primary, 5);
    @include linesd(primary, 5);

    &:hover,
    &:active {
      @include bgcolor(primary, 5);
      @include fgcolor(white);
    }
  }

  topic-repl {
    font-style: italic;
    cursor: pointer;
    @include hover {
      @include fgcolor(primary, 5);
      text-decoration: underline;
    }
  }
</style>
