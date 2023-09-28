<script lang="ts">
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import {
    status_types,
    status_names,
    status_icons,
    status_colors,
  } from '$lib/constants'

  import { SIcon, Gmenu } from '$gui'

  export let nvinfo: CV.Wninfo
  export let ubmemo: CV.Ubmemo
  $: book_status = ubmemo.status

  async function update_status(status: string) {
    if ($_user.privi < 0) return

    try {
      if (status == book_status) status = 'default'
      const path = `/_db/_self/books/${nvinfo.id}/status`
      ubmemo = await api_call(path, { status }, 'PUT')
    } catch (ex) {
      alert(ex)
    }
  }

  $: color = status_colors[book_status]
  $: icon = status_icons[book_status]
  $: name = status_names[book_status]
</script>

<Gmenu class="navi-item" loc="bottom" r>
  <button class="m-btn _{color}" slot="trigger">
    <SIcon name={icon} />
    <span class="u-show-ts">{name}</span>
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
