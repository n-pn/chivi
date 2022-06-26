<script lang="ts">
  import { getContext } from 'svelte'
  import type { Writable } from 'svelte/store'

  import { page, session } from '$app/stores'
  import { SIcon, Gmenu } from '$gui'

  import {
    status_types,
    status_names,
    status_icons,
    status_colors,
  } from '$lib/constants'

  export let nvinfo: CV.Nvinfo
  let ubmemo: Writable<CV.Ubmemo> = getContext('ubmemos')

  $: book_status = $ubmemo.status

  async function update_status(status: string) {
    if ($session.privi < 0) return

    if (status == book_status) status = 'default'

    const url = `/api/_self/books/${nvinfo.id}/status`
    const res = await $page.stuff.api.call(url, 'PUT', { status })

    if (res.error) alert(res.error)
    else $ubmemo = res
  }
</script>

<Gmenu class="navi-item" loc="bottom">
  <button class="m-btn _fill _{status_colors[book_status]}" slot="trigger">
    <SIcon name={status_icons[book_status]} />
    <span>{status_names[book_status]}</span>
  </button>

  <svelte:fragment slot="content">
    {#each status_types as status}
      <button class="gmenu-item" on:click={() => update_status(status)}>
        <SIcon name={status_icons[status]} />
        <span>{status_names[status]}</span>
        {#if status == book_status}
          <span class="-right"><SIcon name="check" /></span>
        {/if}
      </button>
    {/each}
  </svelte:fragment>
</Gmenu>
