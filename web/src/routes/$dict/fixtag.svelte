<script context="module" lang="ts">
  import { appbar, vdict } from '$lib/stores'
  import { rel_time } from '$utils/time_utils'
  export async function load({ fetch, url }) {
    appbar.set({ left: [['Fix Tag', 'pencil', '/$dict']] })

    const source = url.searchParams.get('source') || 'ptags-united'
    const target = url.searchParams.get('target') || 'regular'

    const api_url = `/api/vpinits/fixtag/${source}/${target}`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }

  export interface Data {
    ptag: string
    attr: string

    key: string
    val: string
    uname: string
    mtime: number
  }
</script>

<script lang="ts">
  import { ztext } from '$lib/stores'
  import Lookup, { ctrl as lookup } from '$gui/parts/Lookup.svelte'
  import Upsert from '$gui/parts/Upsert.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let source: string
  export let target: string
  export let data: Array<Data> = []

  const epoch = 1630429200
  let value = []

  async function resolve(idx: number, tag: string) {
    if (!tag) return

    const term = data[idx]
    data = data.filter((_, i) => i != idx)
    value = []

    await fetch(`/api/vpinits/upsert/${target}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key: term.key, val: term.val, tag }),
    })
  }

  function show_lookup(key: string) {
    ztext.put(key)
    lookup.show(true)
  }
</script>

<svelte:head>
  <title>Fix dict - Chivi</title>
</svelte:head>

<article class="m-article">
  <h1>Source: <code>{source}</code>, target: <code>{target}</code></h1>

  <table>
    <thead>
      <th>Uname</th>
      <th>Mtime</th>
      <th>Key</th>
      <th>Val</th>
      <th>Chivi</th>
      <th>Baidu</th>
      <th>Custom</th>
    </thead>

    <tbody>
      {#each data as { ptag, attr, key, val, uname, mtime }, idx}
        {@const fresh = mtime > epoch}
        <tr>
          <td>{uname}</td>
          <td class="mtime">{rel_time(mtime)}</td>
          <td class="key" on:click={() => show_lookup(key)}>{key}</td>
          <td><span class="val">{val}</span></td>
          <td
            ><button
              class="m-btn _xs"
              class:_primary={fresh}
              on:click={() => resolve(idx, attr)}>{attr}</button
            ></td>
          <td
            ><button
              class="m-btn _xs"
              class:_success={!fresh}
              on:click={() => resolve(idx, attr)}>{ptag}</button
            ></td>
          <td class="action">
            <input class="m-input _xs" type="text" bind:value={value[idx]} />
            <button class="m-btn _xs" on:click={() => resolve(idx, value[idx])}
              ><SIcon name="send" /></button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</article>

<Lookup />
<Upsert />

<style lang="scss">
  article {
    margin: 1rem auto;
    padding: var(--gutter);
    max-width: 52rem;

    @include border();
    @include shadow();
    @include bdradi();
  }

  .mtime {
    @include ftsize(xs);
  }

  .key {
    cursor: help;
  }

  th,
  td {
    @include ftsize(sm);
    text-align: center !important;
  }

  .m-input {
    width: 1.75rem;
    padding: 0 !important;
    text-align: center;
  }
</style>
