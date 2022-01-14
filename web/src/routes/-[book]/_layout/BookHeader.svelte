<script context="module">
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'
  import { call_api } from '$api/_api_call'

  import { kit_chap_url } from '$utils/route_utils'
  import { status_types, status_names, status_icons } from '$lib/constants.js'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Appbar from '$lib/sects/Appbar.svelte'

  $: ubmemo = $page.stuff.ubmemo || {}
  $: nvinfo = $page.stuff.nvinfo || {}
  $: status = ubmemo.status || 'default'

  async function update_ubmemo(status) {
    if ($session.privi < 0) return
    if (status == ubmemo.status) status = 'default'
    ubmemo.status = status

    const url = `_self/books/${nvinfo.id}/status`
    const [stt, msg] = await call_api(fetch, url, { status }, 'PUT')
    if (stt) return console.log(`error update book status: ${msg}`)
    else invalidate(`/api/books/${nvinfo.bslug}`)
  }
</script>

<Appbar>
  <a slot="left" href="/-{nvinfo.bslug}" class="header-item _active">
    <SIcon name="book" />
    <span class="header-text _title">{nvinfo.hname}</span>
  </a>

  <svelte:fragment slot="right">
    {#if $session.privi > 0}
      <div class="header-item _menu" class:_disable={$session.privi < 0}>
        <SIcon name={status_icons[status]} />

        <span class="header-text _show-md">{status_names[status]}</span>

        <div class="header-menu">
          {#each status_types as status}
            <div class="-item" on:click={() => update_ubmemo(status)}>
              <SIcon name={status_icons[status]} />
              <span>{status_names[status]}</span>

              {#if status == status}
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
      <a class="header-item" href={kit_chap_url(nvinfo.bslug, ubmemo)}>
        <SIcon name={ubmemo.locked ? 'player-skip-forward' : 'player-play'} />
        <span class="header-text _show-lg">Đọc tiếp</span>
      </a>
    {:else}
      <a
        class="header-item"
        href={kit_chap_url(nvinfo.bslug, { ...ubmemo, chidx: 1 })}>
        <SIcon name="player-play" />
        <span class="header-text _show-lg">Đọc thử</span>
      </a>
    {/if}
  </svelte:fragment>
</Appbar>
