<script context="module">
  export async function dict_search(term, bdic) {
    const url = `/_search?term=${term}&bdic=${bdic}`
    const res = await fetch(url)

    const data = await res.json()
    return data
  }

  export async function dict_upsert(dname, key, vals) {
    const url = `/_upsert?dname=${dname}`
    const res = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ key, vals }),
    })

    const data = await res.json()
    // console.log({ data })
    return data.status
  }

  export function generate_hints(meta, reject, accept) {
    let res = [
      ...meta.special.vals,
      ...meta.special.hints,
      ...meta.generic.vals,
      ...meta.generic.hints,
      ...meta.suggest,
    ]
    if (accept && accept !== '') res.push(accept)

    return res.filter(
      (v, i, s) =>
        v !== reject && v.toLowerCase() !== meta.hanviet && s.indexOf(v) === i
    )
  }

  export function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1)
  }

  export function titleize(input, count = 9) {
    const res = input.split(' ')
    if (count > res.length) count = res.length

    for (let i = 0; i < count; i++) res[i] = capitalize(res[i])
    for (let i = count; i < res.length; i++) res[i] = res[i].toLowerCase()

    return res.join(' ')
  }

  export function compare_power(user, prev) {
    if (user < prev) return [false, 'text']
    else if (user == prev) return [false, 'line']
    else return [true, 'solid']
  }

  export function compare_value(new_val, old_val) {
    if (new_val == '') return ['harmful', 'Xoá từ']
    else if (old_val == '') return ['success', 'Thêm từ']
    else return ['primary', 'Sửa từ']
  }
</script>

<script>
  import { onMount } from 'svelte'
  import relative_time from '$utils/relative_time'
  import Footer from './Upsert/Footer.svelte'

  const tabs = [
    ['special', 'VP riêng'],
    ['generic', 'VP chung'],
    // ['hanviet', 'Hán việt'],
  ]

  export let key = ''
  export let tab = 'generic'
  export let dname = ''
  export let actived = true
  export let changed = false

  import { user } from '$src/stores'
  $: uname = $user.uname
  $: power = $user.power

  let inp_field
  let out_field

  onMount(() => {
    if (key == '') inp_field.focus()
    else out_field.focus()
  })

  let meta = {
    hanviet: '',
    binh_am: '',
    suggest: [],
    generic: { vals: [], hints: [], mtime: 0, uname: '', power: 0 },
    special: { vals: [], hints: [], mtime: 0, uname: '', power: 0 },
  }

  $: current = meta[tab]
  $: existed = current.vals[0] || ''
  $: updated = out_val != existed

  $: [prevail, btn_power] = compare_power($user.power, current.power)
  $: [btn_class, btn_label] = compare_value(out_val, existed)

  $: if (key) preload_input()

  async function preload_input() {
    out_val = ''
    meta = await dict_search(key, dname)
    update_val()
  }

  let out_val = ''
  let hints = []

  function change_tab(new_tab) {
    tab = new_tab
    update_val()
  }

  function update_val(new_val) {
    new_val = new_val || meta[tab].vals[0]

    if (new_val) {
      out_val = new_val
      hints = generate_hints(meta, out_val)
    } else {
      let new_val = meta.hanviet
      if (tab == 'special') new_val = titleize(new_val, 9)

      hints = generate_hints(meta, new_val)
      if (hints.length > 0) out_val = hints[hints.length - 1]
      else out_val = new_val
    }

    out_field.focus()
  }

  async function submit_val() {
    const target = tab == 'special' ? dname : 'generic'
    const status = await dict_upsert(target, key, out_val)

    changed = status === 'ok' && updated
    actived = false
  }

  function upcase_val(count = 100) {
    const new_val = titleize(out_val, count)
    update_val(new_val)
  }

  function handle_enter(evt) {
    if (evt.keyCode == 13) {
      evt.preventDefault()
      return submit_val()
    }
  }

  function handle_keypress(evt) {
    if (evt.keyCode == 13) {
      evt.preventDefault()
      return submit_val()
    }

    if (evt.keyCode === 27) {
      evt.preventDefault()
      return (actived = false)
    }

    if (!evt.altKey) return
    evt.preventDefault()

    switch (evt.keyCode) {
      case 49:
        upcase_val(1)
        break

      case 50:
        upcase_val(2)
        break

      case 51:
        upcase_val(3)
        break

      case 52:
        upcase_val(9)
        break

      case 48:
      case 53:
      case 192:
        upcase_val(0)
        break

      case 88:
        change_tab('special')
        break

      case 67:
        change_tab('generic')
        break

      default:
        break
    }
  }
</script>

<style lang="scss">
  $gutter: 0.75rem;

  .container {
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    @include bgcolor(rgba(#000, 0.65));
  }

  .dialog {
    width: rem(30);
    min-width: 320px;
    max-width: 100%;
    // margin-top: -10%;
    @include bgcolor(neutral, 1);
    @include radius();
    @include shadow(3);
  }

  $header-height: 2.75rem;
  $header-gutter: 0.5rem;

  .header {
    position: relative;
    // padding: $header-gutter $gutter;
    height: $header-height;

    display: flex;
    @include border($sides: bottom, $shade: 3);

    .m-button {
      margin: 0.25rem 0.5rem;
      // top: 0.375rem;
      @include hover {
        color: color(primary, 5);
      }
    }
  }

  .label {
    line-height: $header-height;
    text-transform: uppercase;
    @include font-size(2);
    font-weight: 500;
    margin: 0 0.75rem;
    @include fgcolor(neutral, 6);
  }

  .hanzi {
    display: inline-block;
    margin: 0.375rem 0;

    padding: 0 0.375rem;
    line-height: $header-height - 0.875rem;

    flex-grow: 1;

    @include truncate(null);
    @include radius();

    @include bgcolor(neutral, 1);
    @include border($color: color(neutral, 1));

    &:focus {
      // @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 4);
    }
  }

  .tabs {
    margin-top: 0.75rem;
    @include border($sides: bottom);
    @include flex($gap: 0.5rem);
    padding: 0 0.75rem;
    height: 2rem;
    line-height: 2rem;
    // justify-content: center;
  }

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;
    height: 2rem;
    margin-top: 0.25px;

    @include font-size(2);
    @include fgcolor(neutral, 6);

    @include radius();
    @include radius(0, $sides: bottom);

    @include border($color: neutral);
    @include border($color: none, $sides: bottom);

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
      // @include bdwidth(2px, $sides: top);
      @include bdcolor($color: none, $sides: bottom);
    }
  }

  .body {
    @include bgcolor(#fff);
    padding: 0.75rem;
  }

  $label-width: 3rem;

  $suggests-height: 2rem;
  $titleize-height: 2rem;
  $val-line-height: 2.5rem;

  .output {
    @include bgcolor(neutral, 1);
  }

  .val-field {
    display: block;
    width: 100%;

    margin: 0;

    line-height: 1.5rem;
    padding: 0.75rem;

    outline: none;
    @include border();
    @include bgcolor(neutral, 1);

    &:focus,
    &:active {
      @include bgcolor(white);
      @include bdcolor($color: primary, $shade: 3);
    }

    &._fresh {
      font-style: italic;
    }
  }

  .hints {
    // width: 100%;
    // height: $suggests-height;

    padding: 0.25rem 0.5rem;

    @include border();
    border-bottom: none;
    @include radius($sides: top);

    @include flex($gap: 0.25rem, $child: '.-hint');
    @include font-size(2);

    .-hint {
      font-style: italic;
      line-height: 1.5rem;
      height: 1.5rem;

      padding: 0 0.25rem;
      max-width: 25vw;
      @include truncate(null);

      @include fgcolor(neutral, 6);
      @include bgcolor(neutral, 1);
      @include radius;
      &:hover {
        cursor: pointer;
        @include fgcolor(primary, 6);
        @include bgcolor(primary, 1);
      }

      &._right {
        margin-left: auto;
      }
    }
  }

  .format {
    display: flex;
    padding: 0 0.5rem;

    @include border();
    border-top: none;
    @include radius($sides: bottom);

    font-size: rem(10px);
    @include screen-min(sm) {
      font-size: rem(11px);
    }
    @include screen-min(md) {
      font-size: rem(12px);
    }

    .-cap,
    .-etc {
      display: flex;
    }

    .-etc {
      margin-left: auto;
    }

    .-btn {
      display: inline-block;
      cursor: pointer;
      padding: 0 0.375rem;
      line-height: 2.25rem;
      font-weight: 500;
      text-transform: uppercase;

      max-width: 14vw;
      @include truncate(null);
      @include fgcolor(neutral, 5);

      @include hover {
        @include fgcolor(primary, 5);
        @include bgcolor(#fff);
      }
    }
  }

  .edit {
    font-style: italic;

    line-height: 2.25rem;
    @include fgcolor(neutral, 6);
    @include font-size(2);

    .-time,
    .-user {
      font-weight: 500;
      @include fgcolor(primary, 8);
    }
  }

  .footer {
    margin-top: 0.75rem;

    @include flex($gap: 0.5rem, $child: '.m-button');

    .m-button {
      margin-left: auto;
    }
  }
</style>

<svelte:window on:keydown={handle_keypress} />

<div class="container" on:click={() => (actived = false)}>
  <div class="dialog" on:click|stopPropagation={() => out_field.focus()}>
    <header class="header">
      <span class="label">Thêm từ:</span>

      <span
        class="hanzi"
        role="textbox"
        contenteditable="true"
        on:click|stopPropagation={() => inp_field.focus()}
        bind:textContent={key}
        bind:this={inp_field} />

      <button
        type="button"
        class="m-button _text"
        on:click={() => (actived = false)}>
        <svg class="m-icon _x">
          <use xlink:href="/icons.svg#x" />
        </svg>
      </button>
    </header>

    <section class="tabs">
      {#each tabs as [name, label]}
        <span
          class="tab"
          class:_active={name == tab}
          on:click={() => change_tab(name)}>
          {label}
        </span>
      {/each}
    </section>

    <section class="body">
      <div class="output">
        <div class="hints">
          <span class="-hint" on:click={() => update_val(meta.hanviet)}>
            {meta.hanviet}
          </span>

          {#each hints as hint}
            <span class="-hint" on:click={() => update_val(hint)}>{hint}</span>
          {/each}

          <span class="-hint _right">[{meta.binh_am}]</span>
        </div>

        <input
          type="text"
          lang="vi"
          class="val-field"
          class:_fresh={!existed}
          name="value"
          id="out_field"
          on:keypress={handle_enter}
          bind:this={out_field}
          bind:value={out_val} />

        <div class="format">
          <div class="-cap">
            <span class="-btn" on:click={() => upcase_val(1)}>Hoa 1 chữ</span>
            <span class="-btn" on:click={() => upcase_val(2)}>Hai chữ</span>
            <span class="-btn" on:click={() => upcase_val(3)}>Ba chữ</span>
            <span class="-btn" on:click={() => upcase_val(9)}>Toàn bộ</span>
            <span class="-btn" on:click={() => upcase_val(0)}>Không hoa</span>
          </div>

          <div class="-etc">
            {#if updated}
              <span class="-btn" on:click={() => update_val(existed)}>
                Phục
              </span>
            {/if}
            <span class="-btn" on:click={() => (out_val = '')}>Xoá</span>
          </div>
        </div>
      </div>

      <div class="footer">
        {#if current.uname != ''}
          <div class="edit">
            <span class="-text">Lưu:</span>
            <span class="-time">{relative_time(current.mtime)}</span>
            <span class="-text">bởi</span>
            <span class="-user">{current.uname}</span>
            <span class="-text">(quyền hạn: {current.power})</span>
          </div>
        {/if}

        <button
          type="button"
          class="m-button _{btn_class} _{btn_power}"
          disabled={!(updated || prevail)}
          on:click|once={submit_val}>
          <span class="-text">{btn_label}</span>
        </button>
      </div>
    </section>

    <Footer {key} />
  </div>
</div>
