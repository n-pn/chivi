<script context="module" lang="ts">
  import { rel_time } from '$utils/time_utils'

  import * as api from '$lib/api_call'

  export async function load({ fetch, url }) {
    const source = url.searchParams.get('source') || 'ptags-united'
    const target = url.searchParams.get('target') || 'regular'

    const api_url = `/api/vpinits/fixtag/${source}/${target}`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }

  export interface Data {
    key: string
    val: string

    uname: string
    mtime: number

    attr: string
    ptags: Record<string, number>
  }
</script>

<script lang="ts">
  import { ztext } from '$lib/stores'
  import Lookup, { ctrl as lookup } from '$gui/parts/Lookup.svelte'
  import Upsert from '$gui/parts/Upsert.svelte'

  import { MainApp, BarItem, SIcon } from '$gui'

  export let source: string
  export let target: string
  export let data: Array<Data> = []

  const epoch = 1630429200
  let value = map_tags(data)

  function map_tags(data: Data[]) {
    return data.map(({ ptags, attr }) => {
      if (attr == 'd' && ptags.v) return 'vd'
      if (attr == 'b' && ptags.n) return 'na'
      if (ptags.m) return 'mq'
      if (ptags.v) return 'vi'

      return attr
    })
  }

  async function resolve(idx: number, tag: string) {
    if (!tag) return

    const term = data[idx]
    const params = { key: term.key, val: term.val, tag }
    await api.put(`vpinits/upsert/${target}`, params)

    data = data.filter((_, i) => i != idx)
    value = map_tags(data)
  }

  function show_lookup(key: string) {
    ztext.put(key)
    lookup.show(true)
  }

  function render_count(count: number) {
    if (count < 1000) return count
    return Math.round(count / 1000) + 'k'
  }
</script>

<svelte:head>
  <title>Fix dict - Chivi</title>
</svelte:head>

<MainApp>
  <svelte:fragment slot="header-left">
    <BarItem this="span" icon="pencil" text="Phân loại" show="tm" />
  </svelte:fragment>

  <article class="m-article">
    <h1>Source: <code>{source}</code>, target: <code>{target}</code></h1>

    <table>
      <thead>
        <th>#</th>
        <th>Uname</th>
        <th>Mtime</th>
        <th>Key</th>
        <th>Val</th>
        <th>Chivi</th>
        <th>Baidu</th>
        <th>Custom</th>
      </thead>

      <tbody>
        {#each data as { attr, key, val, uname, mtime, ptags }, idx (key)}
          {@const fresh = mtime > epoch}
          <tr>
            <td class="idx">{idx + 1}</td>
            <td class="uname">{uname}</td>
            <td class="mtime">{rel_time(mtime)}</td>
            <td class="key" on:click={() => show_lookup(key)}>{key}</td>
            <td class="val"><span>{val}</span></td>
            <td
              ><button
                class="m-btn _xs"
                class:_primary={fresh}
                on:click={() => resolve(idx, attr)}>{attr}</button
              ></td>
            <td>
              {#each Object.entries(ptags) as [ptag, count], i2}
                <button
                  class="m-btn _xs"
                  class:_success={!fresh && i2 == 0}
                  on:click={() => resolve(idx, ptag)}
                  >{ptag} ({render_count(count)})</button
                >{/each}
            </td>
            <td class="action">
              <input class="m-input _xs" type="text" bind:value={value[idx]} />
              <button
                class="m-btn _xs"
                on:click={() => resolve(idx, value[idx])}
                ><SIcon name="send" /></button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </article>
</MainApp>

<Lookup />
<Upsert />

<style lang="scss">
  article {
    margin: 1rem var(--gutter);
    padding: var(--gutter);

    @include border();
    @include shadow();
    @include bdradi();
  }

  .idx {
    max-width: 3rem;
  }

  .uname {
    max-width: 5rem;
  }

  .mtime {
    @include ftsize(xs);
  }

  .key {
    cursor: help;
    max-width: 6rem;
    @include clamp($width: null);
  }

  .val {
    // display: inline-block;
    max-width: 8rem;
    @include clamp($width: null);
  }

  th,
  td {
    @include ftsize(sm);
    text-align: center !important;
  }

  button + button {
    margin-left: 0.25rem;
  }

  .m-input {
    width: 1.75rem;
    padding: 0 !important;
    text-align: center;
  }
</style>
