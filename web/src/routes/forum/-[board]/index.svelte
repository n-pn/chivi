<script context="module">
  import { dlabels } from '$lib/constants'

  export async function load({ stuff, fetch, url: { searchParams } }) {
    const { board } = stuff

    const page = +searchParams.get('page') || 1
    const dlabel = searchParams.get('label')

    const api_url = `/api/topics?dboard=${board.id}&page=${page}&take=24`
    const api_res = await fetch(`${api_url}&dlabel=${dlabel || ''}`)

    if (api_res.ok) return { props: { dlabel, content: await api_res.json() } }
    return { status: api_res.status, error: await api_res.text() }
  }
</script>

<script>
  import { page, session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  import DtopicList from '$parts/Dtopic/List.svelte'
  import DtopicForm, { ctrl as dtopic_form } from '$parts/Dtopic/Form.svelte'

  // export let dboard
  export let content = { items: [], pgidx: 1, pgmax: 1 }
  export let dlabel = ''

  $: pager = new Pager($page.url, { page: 1, tl: '' })

  $: nvinfo = $page.stuff.nvinfo
  $: dboard = { id: nvinfo.id, bname: nvinfo.vname, bslug: nvinfo.bslug }
</script>

<board-content>
  <board-filter>
    <span>Lọc nhãn:</span>
    <a href="board" class="m-label _0">
      <span>Tất cả</span>
      {#if !dlabel}<SIcon name="check" /> {/if}
    </a>
    {#each Object.entries(dlabels) as [value, label]}
      <a class="m-label _{value}" href="board?label={value}">
        <span>{label}</span>
        {#if dlabel == value}<SIcon name="check" /> {/if}
      </a>
    {/each}
  </board-filter>

  <DtopicList topics={content.items} {dboard} />

  {#if content.total > 10}
    <board-pagi>
      <Mpager {pager} pgidx={content.pgidx} pgmax={content.pgmax} />
    </board-pagi>
  {/if}

  {#if $session.privi > 2}
    <board-foot>
      <button class="m-btn _primary _fill" on:click={() => dtopic_form.show(0)}>
        <SIcon name="message-plus" />
        <span>Tạo chủ đề mới</span></button>
    </board-foot>
  {/if}

  {#if $dtopic_form.actived}<DtopicForm {dboard} />{/if}
</board-content>

<style lang="scss">
  board-content {
    display: block;
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  board-filter {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;

    justify-content: center;
    margin-bottom: 0.75rem;
  }

  board-pagi {
    display: block;
    margin-top: 0.75rem;
  }

  board-foot {
    display: block;
    text-align: center;
    margin-top: 0.75rem;
    padding-top: 0.75rem;
    @include border($loc: top);
  }
</style>
