<script lang="ts">
  import { session } from '$lib/stores'
  import { api_call } from '$lib/api'

  import {
    status_types,
    status_names,
    status_icons,
    status_colors,
  } from '$lib/constants'

  import { SIcon, Gmenu } from '$gui'

  export let nvinfo: CV.Nvinfo
  export let ubmemo: CV.Ubmemo
  $: book_status = ubmemo.status

  async function update_status(status: string) {
    if ($session.privi < 0) return

    if (status == book_status) status = 'default'

    const url = `/api/_self/books/${nvinfo.id}/status`
    const res = await api_call(url, 'PUT', { status })

    if (res.error) return alert(res.error)
    else ubmemo = res
  }

  $: color = status_colors[book_status]
  $: icon = status_icons[book_status]
  $: name = status_names[book_status]
</script>

<Gmenu class="navi-item" loc="bottom" r>
  <button class="m-btn _{color}" slot="trigger">
    <SIcon name={icon} />
    <span class="u-show-md">{name}</span>
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
