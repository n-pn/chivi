<script context="module">
  import { session } from '$app/stores.js'
  import { invalidate } from '$app/navigation'

  import { put_fetch } from '$api/_api_call'

  import { kit_chap_url } from '$utils/route_utils'
  import { status_types, status_names, status_icons } from '$lib/constants.js'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Header from '$lib/sects/Header.svelte'

  export let cvbook
  export let ubmemo

  $: memo_status = ubmemo.status || 'default'

  async function change_status(status) {
    if ($session.privi < 0) return
    if (status == ubmemo.status) status = 'default'

    const url = `/api/_self/books/${cvbook.id}/status`
    const [stt, msg] = await put_fetch(fetch, url, { status })
    if (stt) return console.log(`error update book status: ${msg}`)
    invalidate(`/api/books/${cvbook.bslug}`)
  }
</script>

<Header>
  <a slot="left" href="/-{cvbook.bslug}" class="header-item _active">
    <SIcon name="book" />
    <span class="header-text _title">{cvbook.htitle}</span>
  </a>

  <svelte:fragment slot="right">
    {#if $session.privi > 0}
      <div class="header-item _menu" class:_disable={$session.privi < 0}>
        <SIcon name={status_icons[memo_status]} />

        <span class="header-text _show-md">{status_names[memo_status]}</span>

        <div class="header-menu">
          {#each status_types as status}
            <div class="-item" on:click={() => change_status(status)}>
              <SIcon name={status_icons[status]} />
              <span>{status_names[status]}</span>

              {#if memo_status == status}
                <span class="_right">
                  <SIcon name="check" />
                </span>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    {/if}

    {#if ubmemo.chidx == 0}
      <div class="header-item _disable" title="Chưa có chương tiết">
        <SIcon name="player-play" />
        <span class="header-text _show-lg">Đọc thử</span>
      </div>
    {:else if ubmemo.chidx > 0}
      <a class="header-item" href={kit_chap_url(cvbook.bslug, ubmemo)}>
        <SIcon name={ubmemo.locked ? 'player-skip-forward' : 'player-play'} />
        <span class="header-text _show-lg">Đọc tiếp</span>
      </a>
    {:else}
      <a
        class="header-item"
        href={kit_chap_url(cvbook.bslug, { ...ubmemo, chidx: 1 })}>
        <SIcon name="player-play" />
        <span class="header-text _show-lg">Đọc thử</span>
      </a>
    {/if}
  </svelte:fragment>
</Header>
