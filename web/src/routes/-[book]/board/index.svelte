<script context="module">
  export async function load({ stuff, fetch, page: { query } }) {
    const { cvbook } = stuff
    const [status, dboard] = await load_board(fetch, cvbook.id)

    if (status) return { status, error: dboard }

    const [status_2, dtopic] = await load_topics(fetch, cvbook.id, query)
    if (status_2) return { status: status_2, error: dtopic }

    return { props: { ...stuff, dboard, dtopic } }
  }

  async function load_board(fetch, id) {
    const url = `/api/boards/${id}`
    const res = await fetch(url)
    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  async function load_topics(fetch, board_id, query) {
    const page = +query.get('page') || 1
    const tlbl = query.get('tl')

    const url = `/api/boards/${board_id}/topics?page=${page}&take=${15}`
    const res = await fetch(tlbl ? `${url}&dlabel=${tlbl}` : url)

    if (res.ok) return [0, await res.json()]
    return [res.status, await res.text()]
  }

  const topic_labels = {
    1: 'Thảo luận',
    2: 'Chia sẻ',
    3: 'Thắc mắc',
    4: 'Yêu cầu',
    5: 'Dịch thuật',
  }
</script>

<script>
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'
  import BookPage from '../_layout/BookPage.svelte'

  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let cvbook
  export let ubmemo
  // export let dboard
  export let dtopic = { items: [], pgidx: 1, pgmax: 1 }

  let form_title = ''
  let form_label = [1]
  let form_error = ''

  $: pager = new Pager($page.path, $page.query, { page: 1, tl: '' })

  async function create_topic() {
    if (form_title.length > 500) {
      return (form_error = 'Tiêu đề quá dài!')
    }

    const url = `/api/boards/${cvbook.id}/new`
    const labels = form_label.map((x) => +x)

    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: form_title, labels }),
    })

    if (res.ok) console.log(await res.json())
    else form_error = await res.text()

    create_new = false
    invalidate(`/api/boards/${cvbook.id}/topics`)
  }

  const _navi = { replace: true, scrollto: '#board' }
</script>

<BookPage {cvbook} {ubmemo} nvtab="board">
  {#if $session.privi > 2}
    <board-content id="board">
      {#each dtopic.items as topic}
        <topic-card>
          <topic-body>
            <a
              class="topic-title"
              href="/-{cvbook.bslug}/board/-{topic.uslug}-{topic.id}">
              {topic.title}
            </a>

            {#each topic.labels as label}
              <a class="topic-label _{label}" href="./board?tl={label}"
                >{topic_labels[label]}</a>
            {/each}
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

      {#if dtopic.total > 10}
        <board-pagi>
          <Mpager {pager} pgidx={dtopic.pgidx} pgmax={dtopic.pgmax} {_navi} />
        </board-pagi>
      {/if}

      <board-form>
        <form
          action="/api/boards/{cvbook.id}/new"
          on:submit|preventDefault={create_topic}
          method="POST">
          <form-field>
            <label class="form-label" for="title">Chủ đề mới</label>
            <textarea
              class="m-input"
              name="title"
              lang="vi"
              bind:value={form_title} />
          </form-field>

          {#if form_error}
            <form-error>{form_error}</form-error>
          {/if}

          <form-foot>
            <form-labels>
              <label-caption>Nhãn:</label-caption>

              {#each Object.entries(topic_labels) as [value, label]}
                <label
                  class="topic-label _{value}"
                  class:_active={form_label.includes(value)}
                  ><input type="checkbox" {value} bind:group={form_label} />
                  <label-name>{label}</label-name>
                  {#if form_label.includes(value)}
                    <SIcon name="check" />
                  {/if}
                </label>
              {/each}
            </form-labels>

            <button
              type="submit"
              class="m-btn _primary _fill"
              disabled={form_title.length < 5 || form_title.length > 200}
              on:click|preventDefault={create_topic}>
              Tạo chủ đề</button>
          </form-foot>
        </form>
      </board-form>
    </board-content>
  {:else}
    <div class="empty">Chức năng đang hoàn thiện :(</div>
  {/if}
</BookPage>

<style lang="scss">
  board-content {
    display: block;
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  board-pagi {
    display: block;
    margin-top: 0.75rem;
  }

  .empty {
    min-height: 20vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);
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
    font-weight: 200;
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
    word-wrap: break-word;

    font-weight: 500;
    line-height: 1.5rem;
  }

  .topic-label {
    display: inline-block;
    line-height: 1.5rem;
    padding: 0 0.375rem;

    font-weight: 500;
    cursor: pointer;

    @include bdradi(0.375rem);
    @include ftsize(sm);

    color: var(--color, #{color(primary, 5)});
    box-shadow: 0 0 0 1px var(--color, #{color(primary, 5)}) inset;

    &:hover,
    &:active,
    &._active {
      background: var(--bgcolor, #{color(primary, 2)});
    }

    &._2 {
      --color: #{color(success, 5)};
      --bgcolor: #{color(success, 2)};
    }

    &._3 {
      --color: #{color(harmful, 5)};
      --bgcolor: #{color(harmful, 1)};
    }

    &._4 {
      --color: #{color(warning, 5)};
      --bgcolor: #{color(warning, 1)};
    }

    &._5 {
      --color: #{color(purple, 5)};
      --bgcolor: #{color(purple, 1)};
    }

    topic-body & + & {
      margin-left: 0.25rem;
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
    @include flex($center: vert, $gap: 0.5rem);
    margin-top: 0.75rem;
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 5.5rem;
    max-height: 10rem;
    font-weight: 500;

    @include ftsize(lg);
    @include fgcolor(secd);
  }

  board-form {
    display: block;
    margin-top: 0.25rem;
  }

  form-labels {
    @include flex($gap: 0.25rem);
    flex: 1;
    flex-wrap: wrap;
    @include ftsize(sm);
  }

  label-caption {
    font-weight: 500;
  }

  form-error {
    display: block;
    line-height: 1.5rem;
    margin-top: 0.25rem;
    margin-bottom: -0.5rem;
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }

  .topic-label > input {
    display: none;
  }
</style>
